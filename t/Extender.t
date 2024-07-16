use strict;
use warnings;
use Test::More;

# Mock implementations of methods
{
    package HashMethods;
    sub set_value { my ($self, $key, $value) = @_; $self->{$key} = $value; }
    sub get_value { my ($self, $key) = @_; return $self->{$key}; }
}

{
    package ArrayMethods;
    sub add_item { my ($self, @items) = @_; push @$self, @items; }
    sub get_item { my ($self, $index) = @_; return $self->[$index]; }
}

{
    package GreetingMethods;
    sub greet { my ($self, $name) = @_; return "Hello, $name!"; }
}

# Load the Extender module
use_ok('Extender');

# Test extending an object with module methods
{
    package TestObject1;
    sub new { bless {}, shift; }

    package main;
    use Extender;
    my $object = TestObject1->new();
    Extend($object, 'HashMethods', 'set_value', 'get_value');

    ok($object->can('set_value'), 'Object can set value');
    ok($object->can('get_value'), 'Object can get value');
}

# Test extending an object with custom methods
{
    package TestObject2;
    sub new { bless {}, shift; }

    package main;
    use Extender;
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
    sub new { bless {}, shift; }

    package TestObject4;
    sub new { bless {}, shift; }

    package main;
    use Extender;
    my $object3 = TestObject3->new();
    my $object4 = TestObject4->new();

    Extend($object3, 'ArrayMethods', 'add_item', 'get_item');
    Extend($object4, 'GreetingMethods', 'greet');

    ok($object3->can('add_item'), 'Object 3 can add item');
    ok($object3->can('get_item'), 'Object 3 can get item');
    ok($object4->can('greet'), 'Object 4 can greet');
}

done_testing();
