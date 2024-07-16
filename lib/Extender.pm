#!/usr/bin/perl

package Extender;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = '1.00';
our @EXPORT = qw(Extend Extends);

=head1 NAME

Extender - Dynamically extend an object with methods from another module

=head1 VERSION

Version 1.00

=cut

=head1 SYNOPSIS

  use Extender;

  # Extend an object with methods from a module
  my $object = MyClass->new();
  Extend($object, 'Some::Class');

  # Extend an object with custom methods
  Extends($object,
      greet => sub { my ($self, $name) = @_; print "Hello, $name!\n"; },
      custom_method => \&some_function,
  );

=head1 DESCRIPTION

The C<Extender> module provides a mechanism to dynamically extend an object
with methods exported by another Perl module. This module allows you to add
methods to any Perl reference ($object), whether it's a hash reference,
an array reference, or a scalar reference.

This approach is powerful because it abstracts away the details of method
creation and allows developers to enhance the capabilities of their data
structures dynamically. It's particularly useful in scenarios where you want
to extend the functionality of existing objects without modifying their
original definitions or hierarchies.

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
    
    # Load the module
    eval "use $module";
    die "Failed to load module $module: $@" if $@;
    
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
            *{ref($object) . "::$name"} = sub { unshift @_, $object; goto &$extend{$name} };
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

=head1 EXAMPLES

=head2 Example of extending an object with all methods from a module

  package MyClass;
  use Extender;

  sub new {
      my $class = shift;
      my $self = bless {}, $class;
      return $self;
  }

  my $object = MyClass->new();
  Extend($object, 'Some::Class');

  # Now $object can use any method from Some::Class
  $object->method1(1, 2, 3, 4);

=head2 Example of extending an object with specific methods from a module

  package AnotherClass;
  use Extender;

  sub new {
      my $class = shift;
      my $self = bless {}, $class;
      return $self;
  }

  my $object = AnotherClass->new();
  Extend($object, 'Some::Class', 'method1', 'method2');

  # Now $object can use method1 and method2 from Some::Class
  $object->method1(1, 2, 3, 4);
  $object->method2(1, 2, 3, 4);

=head2 Example of adding methods using anonymous subroutines and existing functions

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

=head2 Example of adding methods to raw reference variables

#!/usr/bin/perl

use strict;
use warnings;
use Extender;

# Example 1: Hash reference
my $hash_object = {};
my @methods_for_hash = ('set_value', 'get_value');

# Extend $hash_object with methods
Extend($hash_object, 'HashMethods', @methods_for_hash);

# Now $hash_object can use the added methods
$hash_object->set_value('key', 'value');
print $hash_object->get_value('key'), "\n";  # Outputs: value

# Example 2: Array reference
my $array_object = [];
my @methods_for_array = ('add_item', 'get_item');

# Extend $array_object with methods
Extend($array_object, 'ArrayMethods', @methods_for_array);

# Now $array_object can use the added methods
$array_object->add_item('item1');
$array_object->add_item('item2');
print $array_object->get_item(0), "\n";  # Outputs: item1

# Example 3: Scalar reference (assuming it contains a hash reference)
my $scalar_object = {};
my @methods_for_scalar = ('set_property', 'get_property');

# Extend $scalar_object with methods
Extend($scalar_object, 'HashMethods', @methods_for_scalar);

# Now $scalar_object can use the added methods
$scalar_object->set_property('name', 'John');
print $scalar_object->get_property('name'), "\n";  # Outputs: John

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
