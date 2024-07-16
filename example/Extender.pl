#!/usr/bin/perl

### Scenario 1: Extending an Object with Module Methods

package MyObject;
use Extender;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

my $object = MyObject->new();
Extend($object, 'List::Util');  # Extend with List::Util methods

# Using extended methods
print $object->sum(1, 2, 3, 4), "\n";  # Outputs: 10 (sum of elements)
print $object->max(1, 2, 3, 4), "\n";  # Outputs: 4 (maximum value)


### Scenario 2: Adding Custom Methods to an Object

package MyDataStructure;
use Extender;

sub new {
    my $class = shift;
    my $self = bless { data => [] }, $class;
    return $self;
}

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
use Extender;

sub new {
    my $class = shift;
    my $self = bless \"0", $class;
    return $self;
}

package MyClass2;
use Extender;

sub new {
    my $class = shift;
    my $self = bless \"0", $class;
    return $self;
}

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

my $object = {};
my $code_ref = sub { my ($self, $arg) = @_; return "Hello, $arg!"; };

# Extenda $object with a method using reference to scalar with code ref
Extends($object, 'greet' => \$code_ref);

# Using extended method
print $object->greet('Alice'), "\n";  # Outputs: Hello, Alice!
