#!/usr/bin/perl

package Extender;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = '1.00';
our @EXPORT = qw(Extend Extends);

=head1 NAME

Extender - Dynamically enhance Perl objects with additional methods from other modules or custom subroutines

=head1 SYNOPSIS

    use Extender;

    # Example: Extend an object with methods from a module
    my $object = MyClass->new();
    Extend($object, 'Some::Class');
    $object->method_from_some_class();

    # Example: Extend an object with custom methods
    Extends($object,
        greet => sub { my ($self, $name) = @_; print "Hello, $name!\n"; },
        custom_method => sub { return "Custom method executed"; },
    );
    $object->greet('Alice');
    $object->custom_method();

=head1 DESCRIPTION

Extender is a Perl module that facilitates the dynamic extension of objects with methods from other modules or custom-defined subroutines. It allows you to enhance Perl objects—whether hash references, array references, or scalar references—with additional functionalities without altering their original definitions.

=head1 EXPORTED FUNCTIONS

=cut

=head2 Extend($object, $module, @methods)

Extend the provided C<$object> with methods exported by C<$module>.

=over 4

=item * C<$object>

The object to be extended with methods.

=item * C<$module>

The name of the module from which methods should be imported.

=item * C<@methods> (optional)

Optional list of specific methods to import from C<$module>. If not provided,
all functions exported by C<$module> will be added as methods to C<$object>.

=back

=cut

sub Extend {
    my ($object, $module, @methods) = @_;

    # Check if the module is already loaded
    unless (exists $INC{$module} || defined *{"${module}::"}) {
        eval "require $module";
        die "Failed to load module $module: $@" if $@;
    }

    # Get list of functions exported by the module
    no strict 'refs';

    # Add each specified function (or all if none specified) as a method to the object
    foreach my $func ($#methods > -1 ? @methods : @{"${module}::EXPORT"}) {
        *{ref($object) . "::$func"} = sub { unshift @_, $object; goto &{"${module}::$func"} };
    }

    return $object;
}

=head2 Extends($object, %extend)

Extends the provided C<$object> with multiple methods specified in the C<%extend> hash.

=over 4

=item * C<$object>

The object to be extended with methods. It should be a reference, typically a blessed hash reference.

=item * C<%extend>

A hash where the keys are method names and the values are coderefs, references to existing functions,
or references to scalar variables containing coderefs.

=back

If the method already exists in the object, an exception will be thrown. If the method reference is
invalid (i.e., not a coderef or reference to a coderef), an exception will also be thrown.

=cut

sub Extends {
    my ($object, %extend) = @_;

    for my $name (keys %extend) {
        # Check if the method already exists
        if (exists $object->{$name}) {
            die "Method $name already exists in the object";
        }

        # Create the method
        no strict 'refs';
        if (ref $extend{$name} eq 'CODE') {
            # If $extend{$name} is a coderef, directly assign it
            *{ref($object) . "::$name"} = sub { unshift @_, $object; goto &{$extend{$name}} };
        }
        elsif (ref $extend{$name} eq 'SCALAR' && defined ${$extend{$name}} && ref ${$extend{$name}} eq 'CODE') {
            # If $method_ref is a reference to a scalar containing a coderef
            *{ref($object) . "::$name"} = sub { unshift @_, $object; goto &${$extend{$name}} };
        }
        else {
            die "Invalid method reference provided. Expected CODE or reference to CODEREF";
        }
    }

    return $object;
}

=head1 USAGE

=head2 Extend an Object with Methods from a Module

    use Extender;

    # Extend an object with methods from a module
    my $object = MyClass->new();
    Extend($object, 'Some::Class');

    # Now $object can use any method from Some::Class
    $object->method1(1, 2, 3, 4);

=head2 Extend an Object with Custom Methods

    use Extender;

    # Extend an object with custom methods
    my $object = MyClass->new();
    Extends($object,
        greet => sub { my ($self, $name) = @_; print "Hello, $name!\n"; },
        custom_method => \&some_function,
    );

    # Using the added methods
    $object->greet('Alice');               # Output: Hello, Alice!
    $object->custom_method('Hello');       # Assuming some_function prints something

=head2 Adding Methods to Raw Reference Variables

    package HashMethods;

    use strict;
    use warnings;
    use Exporter 'import';
    our @EXPORT = qw(set get);

    sub set {
        my ($self, $key, $value) = @_;
        $self->{$key} = $value;
    }

    sub get {
        my ($self, $key) = @_;
        return $self->{$key};
    }

    1;

    package ArrayMethods;

    use strict;
    use warnings;
    use Exporter 'import';
    our @EXPORT = qw(add get);

    sub add {
        my ($self, $item) = @_;
        push @$self, $item;
    }

    sub get {
        my ($self, $index) = @_;
        return $self->[$index];
    }

    1;

    package ScalarMethods;

    use strict;
    use warnings;
    use Exporter 'import';
    our @EXPORT = qw(set get substr length);

    sub set {
        my ($self, $value) = @_;
        $$self = $value;
    }

    sub get {
        my ($self) = @_;
        return $$self;
    }

    sub substr {
        my $self = shift;
        return substr($$self, @_);
    }

    sub length {
        my ($self) = @_;
        return length $$self;
    }

    1;

    # MAIN 

    package main;

    use strict;
    use warnings;
    use Extender;
    use HashMethods;
    use ArrayMethods;
    use ScalarMethods;

    my $hash_object = {};
    my $array_object = [];
    my $scalar_object = \"";

    # Extend $hash_object with methods from HashMethods
    Extend($hash_object, 'HashMethods', 'set', 'get');

    # Extend $array_object with methods from ArrayMethods
    Extend($array_object, 'ArrayMethods', 'add', 'get');

    # Extend $scalar_object with methods from ScalarMethods
    Extend($scalar_object, 'ScalarMethods', 'set', 'get', 'substr', 'length');

    # Using extended methods for hash object
    $hash_object->set('key', 'value');
    print $hash_object->get('key'), "\n";  # Outputs: value

    # Using extended methods for array object
    $array_object->add('item1');
    $array_object->add('item2');
    print $array_object->get(0), "\n";  # Outputs: item1

    # Using extended methods for scalar object
    $scalar_object->set('John');
    print $scalar_object->get(), "\n";  # Outputs: John
    print $scalar_object->length(), "\n";  # Outputs: 4
    print $scalar_object->substr(1, 2), "\n";  # Outputs: oh
    $scalar_object->substr(1, 2, "ane");
    print $scalar_object->get(), "\n";  # Outputs: Jane

    1;

=head2 Adding methods using anonymous subroutines and existing functions

    use Extender;

    package MyClass;
    sub new {
        my $class = shift;
        my $self = bless {}, $class;
        return $self;
    }

    my $object = MyClass->new();

    Extends($object,
        greet => sub { my ($self, $name) = @_; print "Hello, $name!\n"; },
        custom_method => \&some_function,
    );

    # Using the added methods
    $object->greet('Alice'); # Output: Hello, Alice!
    $object->custom_method('Hello'); # Assuming some_function prints something

=head2 Using Shared Object for Shared Variable functionality

    package main;

    use strict;
    use warnings;
    use threads;
    use threads::shared;
    use Extender;

    # Example methods to manipulate shared data

    # Method to set data in a shared hash
    sub set_hash_data {
        my ($self, $key, $value) = @_;
        lock(%{$self});
        $self->{$key} = $value;
    }

    # Method to get data from a shared hash
    sub get_hash_data {
        my ($self, $key) = @_;
        lock(%{$self});
        return $self->{$key};
    }

    # Method to add item to a shared array
    sub add_array_item {
        my ($self, $item) = @_;
        lock(@{$self});
        push @{$self}, $item;
    }

    # Method to get item from a shared array
    sub get_array_item {
        my ($self, $index) = @_;
        lock(@{$self});
        return $self->[$index];
    }

    # Method to set data in a shared scalar
    sub set_scalar_data {
        my ($self, $value) = @_;
        lock(${$self});
        ${$self} = $value;
    }

    # Method to get data from a shared scalar
    sub get_scalar_data {
        my ($self) = @_;
        lock(${$self});
        return ${$self};
    }

    # Create shared data structures
    my %shared_hash :shared;
    my @shared_array :shared;
    my $shared_scalar :shared;

    # Create shared objects
    my $shared_hash_object = \%shared_hash;
    my $shared_array_object = \@shared_array;
    my $shared_scalar_object = \$shared_scalar;

    # Extend the shared hash object with custom methods
    Extends($shared_hash_object,
        set_hash_data => \&set_hash_data,
        get_hash_data => \&get_hash_data,
    );

    # Extend the shared array object with custom methods
    Extends($shared_array_object,
        add_array_item => \&add_array_item,
        get_array_item => \&get_array_item,
    );

    # Extend the shared scalar object with custom methods
    Extends($shared_scalar_object,
        set_scalar_data => \&set_scalar_data,
        get_scalar_data => \&get_scalar_data,
    );

    # Create threads to manipulate shared objects concurrently

    # Thread for shared hash object
    my $hash_thread = threads->create(sub {
        $shared_hash_object->set_hash_data('key1', 'value1');
        print "Hash thread: key1 = " . $shared_hash_object->get_hash_data('key1') . "\n";
    });

    # Thread for shared array object
    my $array_thread = threads->create(sub {
        $shared_array_object->add_array_item('item1');
        print "Array thread: item at index 0 = " . $shared_array_object->get_array_item(0) . "\n";
    });

    # Thread for shared scalar object
    my $scalar_thread = threads->create(sub {
        $shared_scalar_object->set_scalar_data('shared_value');
        print "Scalar thread: value = " . $shared_scalar_object->get_scalar_data() . "\n";
    });

    # Wait for all threads to finish
    $hash_thread->join();
    $array_thread->join();
    $scalar_thread->join();

    1;
=cut

=head1 AUTHOR

OnEhIppY @ Domero Software <domerosoftware@gmail.com>

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic> and L<perlgpl>.

=head1 SEE ALSO

L<Exporter>, L<perlfunc>, L<perlref>, L<perlsub>

=cut

1;
