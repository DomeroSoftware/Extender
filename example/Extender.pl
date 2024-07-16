#!/usr/bin/perl

### Scenario 1: Extending an Object with Module Methods

    package MyObject;

    sub new {
        my $class = shift;
        my $self = bless {}, $class;
        return $self;
    }

    package main;

    use Extender;

    my $object = MyObject->new();
    Extend($object, 'List::Util');  # Extend with List::Util methods

    # Using extended methods
    print $object->sum(1, 2, 3, 4), "\n";  # Outputs: 10 (sum of elements)
    print $object->max(1, 2, 3, 4), "\n";  # Outputs: 4 (maximum value)


### Scenario 2: Adding Custom Methods to an Object

    package MyDataStructure;

    sub new {
        my $class = shift;
        my $self = bless { data => [] }, $class;
        return $self;
    }

    package main;

    use Extender;

    my $object = MyDataStructure->new();
    Extends($object,
        add_data => sub { my ($self, $item) = @_; push @{$self->{data}}, $item; },
        get_data => sub { my $self = shift; return @{$self->{data}}; },
    );

    # Using custom methods
    $object->add_data('Item 1');
    $object->add_data('Item 2');
    my @data = $object->get_data();
    print "Data: @data\n";  # Outputs: Data: Item 1 Item 2


### Scenario 3: Extending Multiple Objects with Different Modules

    package MyClass1;

    sub new {
        my $class = shift;
        my $self = bless \"0", $class;
        return $self;
    }

    package MyClass2;

    sub new {
        my $class = shift;
        my $self = bless \"0", $class;
        return $self;
    }

    package main;

    use Extender;

    my $object1 = MyClass1->new();
    my $object2 = MyClass2->new();

    # Extend $object1 with List::Util methods
    Extend($object1, 'List::Util');

    # Extend $object2 with Scalar::Util methods
    Extend($object2, 'Scalar::Util');

    # Using extended methods
    print $object1->sum(1, 2, 3, 4), "\n";  # Outputs: 10 (sum of elements)
    print $object2->blessed($object2), "\n";  # Outputs: MyClass2 (class name)


### Scenario 4: Adding Methods to Raw References (Hash, Array, Scalar)

    package main;

    use Extender;

    my $hash_object = {};
    my $array_object = [];
    my $scalar_object = \"";

    # Extend $hash_object with methods
    Extend($hash_object, 'HashMethods', 'set_value', 'get_value');

    # Extend $array_object with methods
    Extend($array_object, 'ArrayMethods', 'add_item', 'get_item');

    # Extend $scalar_object (assuming it contains a hash reference)
    Extend($scalar_object, 'ScalarMethods', 'set', 'get', 'substr', 'length');

    # Using extended methods
    $hash_object->set_value('key', 'value');
    print $hash_object->get_value('key'), "\n";  # Outputs: value

    $array_object->add_item('item1');
    $array_object->add_item('item2');
    print $array_object->get_item(0), "\n";  # Outputs: item1

    $scalar_object->set('John');
    print $scalar_object->get(), "\n";  # Outputs: John


### Scenario 5: Using Reference to Scalar with Code Ref

    package main;

    use Extender;

    my $object = {};
    my $code_ref = sub { my ($self, $arg) = @_; return "Hello, $arg!"; };

    # Extenda $object with a method using reference to scalar with code ref
    Extends($object, 'greet' => \$code_ref);

    # Using extended method
    print $object->greet('Alice'), "\n";  # Outputs: Hello, Alice!


### Scenario 6: Used on shared variables

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

