use strict;
use warnings;
use Test::More;

# Load the Extender module
use_ok('Extender');

# Test extending an object with module methods
{
    package TestObject1;
    use Extender;

    sub new { bless {}, shift; }

    my $object = TestObject1->new();
    Extend($object, 'List::Util');

    ok($object->can('sum'), 'Object can sum');
    ok($object->can('max'), 'Object can find maximum');
}

# Test extending an object with custom methods
{
    package TestObject2;
    use Extender;

    sub new { bless {}, shift; }

    my $object = TestObject2->new();
    Extends($object,
        greet => sub { my ($self, $name) = @_; return "Hello, $name!"; },
        custom_method => sub { return "Custom method executed"; },
    );

    ok($object->can('greet'), 'Object can greet');
    ok($object->can('custom_method'), 'Object can execute custom method');
}

# Test extending objects with methods from different modules
{
    package TestObject3;
    use Extender;

    sub new { bless {}, shift; }

    package TestObject4;
    use Extender;

    sub new { bless {}, shift; }

    my $object3 = TestObject3->new();
    my $object4 = TestObject4->new();

    Extend($object3, 'List::Util');
    Extend($object4, 'Scalar::Util');

    ok($object3->can('sum'), 'Object 3 can sum');
    ok($object4->can('blessed'), 'Object 4 can check blessedness');
}

# Test extending raw references (hash, array, scalar)
{
    my $hash_object = {};
    my $array_object = [];
    my $scalar_object = {};

    Extend($hash_object, 'HashMethods', 'set_value', 'get_value');
    Extend($array_object, 'ArrayMethods', 'add_item', 'get_item');
    Extend($scalar_object, 'HashMethods', 'set_property', 'get_property');

    ok($hash_object->can('set_value'), 'Hash object can set value');
    ok($array_object->can('add_item'), 'Array object can add item');
    ok($scalar_object->can('set_property'), 'Scalar object can set property');
}

# Test using reference to scalar with code ref
{
    my $object = {};
    my $code_ref = sub { my ($self, $arg) = @_; return "Hello, $arg!"; };

    Extend($object, 'GreetingMethods', 'greet' => \$code_ref);

    ok($object->can('greet'), 'Object can greet');
    is($object->greet('Alice'), 'Hello, Alice!', 'Greet method works as expected');
}

done_testing();
