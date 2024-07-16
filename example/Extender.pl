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
    my $scalar_object = {};

    # Extend $hash_object with methods
    Extend($hash_object, 'HashMethods', 'set_value', 'get_value');

    # Extend $array_object with methods
    Extend($array_object, 'ArrayMethods', 'add_item', 'get_item');

    # Extend $scalar_object (assuming it contains a hash reference)
    Extend($scalar_object, 'HashMethods', 'set_property', 'get_property');

    # Using extended methods
    $hash_object->set_value('key', 'value');
    print $hash_object->get_value('key'), "\n";  # Outputs: value

    $array_object->add_item('item1');
    $array_object->add_item('item2');
    print $array_object->get_item(0), "\n";  # Outputs: item1

    $scalar_object->set_property('name', 'John');
    print $scalar_object->get_property('name'), "\n";  # Outputs: John


### Scenario 5: Using Reference to Scalar with Code Ref

    package main;
    use Extender;

    my $object = {};
    my $code_ref = sub { my ($self, $arg) = @_; return "Hello, $arg!"; };

    # Extenda $object with a method using reference to scalar with code ref
    Extends($object, 'greet' => \$code_ref);

    # Using extended method
    print $object->greet('Alice'), "\n";  # Outputs: Hello, Alice!


### Scenario 6: Used on shared data

    package main;

    use strict;
    use warnings;
    use threads;
    use threads::shared;
    use Extender;

    # Define shared data structures
    my %shared_hash :shared;
    my @shared_array :shared;
    my $shared_scalar :shared;

    # Example method to set data in shared hash (simulated delay)
    sub set_hash_data {
        my ($self, $key, $value) = @_;
        lock(%{$self});  # Lock the shared hash for write
        sleep 1;  # Simulate some time-consuming operation
        $self->{$key} = $value;
        unlock(%{$self});  # Unlock the shared hash
    }

    # Example method to get data from shared hash (simulated delay)
    sub get_hash_data {
        my ($self, $key) = @_;
        lock(%{$self});  # Lock the shared hash for read
        sleep 1;  # Simulate some time-consuming operation
        my $value = $self->{$key};
        unlock(%{$self});  # Unlock the shared hash
        return $value;
    }

    # Example method to push data into shared array (simulated delay)
    sub push_array_data {
        my ($self, $value) = @_;
        lock(@{$self});  # Lock the shared array for write
        sleep 1;  # Simulate some time-consuming operation
        push @{$self}, $value;
        unlock(@{$self});  # Unlock the shared array
    }

    # Example method to pop data from shared array (simulated delay)
    sub pop_array_data {
        my ($self) = @_;
        lock(@{$self});  # Lock the shared array for write
        sleep 1;  # Simulate some time-consuming operation
        my $value = pop @{$self};
        unlock(@{$self});  # Unlock the shared array
        return $value;
    }

    # Example method to set data in shared scalar (simulated delay)
    sub set_scalar_data {
        my ($self, $value) = @_;
        lock(${$self});  # Lock the shared scalar for write
        sleep 1;  # Simulate some time-consuming operation
        ${$self} = $value;
        unlock(${$self});  # Unlock the shared scalar
    }

    # Example method to get data from shared scalar (simulated delay)
    sub get_scalar_data {
        my ($self) = @_;
        lock(${$self});  # Lock the shared scalar for read
        sleep 1;  # Simulate some time-consuming operation
        my $value = ${$self};
        unlock(${$self});  # Unlock the shared scalar
        return $value;
    }

    # Create objects from shared data structures
    my $object_hash = \%shared_hash;
    my $object_array = \@shared_array;
    my $object_scalar = \$shared_scalar;

    # Extend shared objects with custom methods using Extender
    Extends($object_hash,
        set_data => \&set_hash_data,
        get_data => \&get_hash_data,
    );

    Extends($object_array,
        push_data => \&push_array_data,
        pop_data => \&pop_array_data,
    );

    Extends($object_scalar,
        set_data => \&set_scalar_data,
        get_data => \&get_scalar_data,
    );

    # Create threads to manipulate shared objects concurrently
    my @threads;
    for my $i (1 .. 3) {
        push @threads, threads->create(sub {
            my $tid = threads->self->tid;

            # Thread using shared hash object
            $object_hash->set_data("key$i", "value$i");
            my $hash_data = $object_hash->get_data("key$i");
            print "Thread $tid: Retrieved hash data: $hash_data\n";

            # Thread using shared array object
            $object_array->push_data("item$i");
            my $array_data = $object_array->pop_data();
            print "Thread $tid: Retrieved array data: $array_data\n";

            # Thread using shared scalar object
            $object_scalar->set_data("scalar_value$i");
            my $scalar_data = $object_scalar->get_data();
            print "Thread $tid: Retrieved scalar data: $scalar_data\n";
        });
    }

    # Wait for all threads to finish
    $_->join for @threads;

