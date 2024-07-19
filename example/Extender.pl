#!/usr/bin/perl

### Scenario 1: Extending an Object with Module Methods

    package MyMethods;

    use strict;
    use warnings;
    use Exporter 'import';
    our @EXPORT = qw(increment_value display_value);

    sub increment_value {
        my ($self, $key) = @_;
        $self->{$key}++ if exists $self->{$key};
    }

    sub display_value {
        my ($self, $key) = @_;
        print "$key: ", $self->{$key} // 'undefined', "\n";
    }

    package MyObject;

    sub new {
        my $class = shift;
        my $self = bless { count => 0 }, $class;
        return $self;
    }

    package main;

    use strict;
    use warnings;
    use Extender;

    my $object = MyObject->new();

    # Extend the object with methods from MyMethods
    Extend($object, 'MyMethods');

    # Using extended methods
    $object->increment_value('count');
    $object->display_value('count');  # Outputs: count: 1

    $object->increment_value('count');
    $object->display_value('count');  # Outputs: count: 2

    1;

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

    1;

### Scenario 3: Extending Multiple Objects with Different Modules

    package MyMethods;

    use strict;
    use warnings;
    use Exporter 'import';
    our @EXPORT = qw(increment_value display_value);

    sub increment_value {
        my ($self, $value) = @_;
        $$self += $value;
    }

    sub display_value {
        my ($self) = @_;
        print "Value: $$self\n";
    }

    package MyClass1;

    sub new {
        my $class = shift;
        my $self = bless \0, $class;
        return $self;
    }

    package MyClass2;

    sub new {
        my $class = shift;
        my $self = bless \0, $class;
        return $self;
    }

    package main;

    use strict;
    use warnings;
    use Extender;
    use MyMethods;

    my $object1 = MyClass1->new();
    my $object2 = MyClass2->new();

    # Extend $object1 with MyMethods
    Extends($object1,
        increment_value => \&MyMethods::increment_value,
        display_value   => \&MyMethods::display_value,
    );

    # Extend $object2 with MyMethods
    Extends($object2,
        increment_value => \&MyMethods::increment_value,
        display_value   => \&MyMethods::display_value,
    );

    # Using extended methods
    $object1->increment_value(10);
    $object1->display_value();  # Outputs: Value: 10

    $object2->increment_value(20);
    $object2->display_value();  # Outputs: Value: 20

    1;

### Scenario 4: Adding Methods to Raw References (Hash, Array, Scalar)

    # PACKAGES

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

### Scenario 5: Using Reference to Scalar with Code Ref

    package main;

    use Extender;

    my $object = {};
    my $code_ref = sub { my ($self, $arg) = @_; return "Hello, $arg!"; };

    # Extenda $object with a method using reference to scalar with code ref
    Extends($object, 'greet' => \$code_ref);

    # Using extended method
    print $object->greet('Alice'), "\n";  # Outputs: Hello, Alice!

    1;

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

    1;

# Alias - The Alias function creates an alias for an existing method on an object.

    package MyClass;

    sub new {
        my $class = shift;
        my $self = bless {}, $class;
        return $self;
    }

    sub original_method {
        return "Original method";
    }

    package main;

    use Extender;

    my $object = MyClass->new();

    # Create an alias for 'original_method' as 'alias_method'
    Alias($object, 'alias_method', 'original_method');

    # Using the alias method
    print $object->alias_method(), "\n";  # Outputs: Original method

    1;

# Unload - The Unload function removes a method from an object.

    package MyClass;

    sub new {
        my $class = shift;
        my $self = bless {}, $class;
        return $self;
    }

    sub method1 {
        return "Method 1";
    }

    sub method2 {
        return "Method 2";
    }

    package main;

    use Extender;

    my $object = MyClass->new();

    # Before Unload
    print $object->method1(), "\n";  # Outputs: Method 1
    print $object->method2(), "\n";  # Outputs: Method 2

    # Unload 'method1'
    Unload($object, 'method1');

    # After Unload
    # 'method1' should not be available
    eval {
        $object->method1();
    };
    warn "Error: $@" if $@;  # Outputs: Error: Can't locate object method "method1" via package

    # 'method2' should still be available
    print $object->method2(), "\n";  # Outputs: Method 2

    1;

# AddMethod - The AddMethod function dynamically adds a new method to an object.

    package MyClass;

    sub new {
        my $class = shift;
        my $self = bless {}, $class;
        return $self;
    }

    package main;

    use Extender;

    my $object = MyClass->new();

    # Add a new method 'new_method'
    AddMethod($object, 'new_method', sub { return "New method"; });

    # Using the added method
    print $object->new_method(), "\n";  # Outputs: New method

    1;

# Decorate - The Decorate function wraps an existing method on an object with additional behavior.

    package MyClass;

    sub new {
        my $class = shift;
        my $self = bless {}, $class;
        return $self;
    }

    sub original_method {
        return "Original method";
    }

    package main;

    use Extender;

    my $object = MyClass->new();

    # Decorate 'original_method'
    Decorate($object, 'original_method', sub {
        my ($self, $original, @args) = @_;
        return "Before: " . $original->($self, @args) . " After";
    });

    # Using the decorated method
    print $object->original_method(), "\n";  # Outputs: Before: Original method After

    1;

# ApplyRole - The ApplyRole function applies methods from a role package to an object.

    package TestRole;

    sub apply {
        my ($class, $object) = @_;
        no strict 'refs';
        *{$object . "::new_method"} = sub { return "New method"; };
    }

    package MyClass;

    sub new {
        my $class = shift;
        my $self = bless {}, $class;
        return $self;
    }

    package main;

    use Extender;

    my $object = MyClass->new();

    # Apply 'TestRole' to $object
    ApplyRole($object, 'TestRole');

    # Using the applied method
    print $object->new_method(), "\n";  # Outputs: New method

    1;

# InitHook - The InitHook function attaches initialization and destruction hooks to an object.

    package MyClass;

    use Extender;

    sub new {
        my $class = shift;

        # Initialization $self
        my $self = Extend({}, 'Extender');

        # Initialization INIT hook
        $self->InitHook('INIT', sub { print "Initializing object\n" });

        # Destruction DESTRUCT hook
        $self->InitHook('DESTRUCT', sub { print "Destructing object\n" });

        return bless $self, $class
    }

    package main;

    use MyClass;

    # Creating an instance triggers INIT hook
    my $object = MyClass->new();  # Outputs: Initializing object

    # Destroying an instance triggers DESTRUCT hook
    undef $object;  # Outputs: Destructing object

    1;

# Creating Extender Class objects from any (even shared) reference typed variable except for CODE refrerences

    package main;

    use Extender;

    my $object = Extend({},'Extender');
    $object->Extends( method => sub { return "method"; } );
    print $object->method(), "\n";  # Outputs: method

    my $array = Extend([],'Extender');
    $array->Extends( method => sub { return "method"; } );
    print $array->method(), "\n";  # Outputs: method

    my $scalar = Extend(\"",'Extender');
    $scalar->Extends( method => sub { return "method"; } );
    print $scalar->method(), "\n";  # Outputs: method

    my $glob = Extend(\*GLOB,'Extender');
    $glob->Extends( method => sub { return "method"; } );
    print $glob->method(), "\n";  # Outputs: method

    1;
