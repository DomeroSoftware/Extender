use strict;
use warnings;
use Test::More;

# Check for Test::Exception module
eval {
    require Test::Exception;
    Test::Exception->import();
};
plan skip_all => "Test::Exception not installed" if $@;

# Plan the number of tests you expect to run
plan tests => 29;

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

# Mock role classes
{
    package MockRole;
    sub apply {
        my ($class, $object) = @_;
        no strict 'refs';
        *{ref($object) . "::new_method"} = sub { return "New method"; };
    }
}

# Mock norole classes
{
    package MockNoRole;
    sub new {
        my ($class, $object) = @_;
        return bless $object, $class
    }
}


# Moose
{
    package MooseX::Role::Parameterized::Extender::MockTestRole;
    sub apply {
        my ($class, $object) = @_;
        no strict 'refs';
        *{ref($object) . "::new_method"} = sub { return "New method"; };
    }
    sub new_method { my $self=shift; return $self }
}

{
    package MooseX::Role::Parameterized::Extender::MockNoTestRole;
    sub new_method { my $self=shift; return $self }
}

package main;

# Load the Extender module
use_ok('Extender');

# Test Extend function
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

# Test Extends function
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

# Test Override function
{
    package TestObject5;
    sub new { bless {}, shift; }
    sub existing_method { return "Original method"; }

    package main;
    use Extender;
    my $object = TestObject5->new();
    Override($object, 'existing_method', sub { return "New method"; });

    is($object->existing_method(), "New method", "Override existing method");
}

# Test Alias function
{
    package TestObject6;
    sub new { bless {}, shift; }
    sub original_method { return "Original method"; }

    package main;
    use Extender;
    my $object = TestObject6->new();
    Alias($object, 'original_method', 'alias_method');

    is($object->alias_method(), "Original method", "Alias method should return original method");
}

# Test Unload function
{
    package TestObject7;
    sub new { bless {}, shift; }
    sub method1 { return "Method 1"; }
    sub method2 { return "Method 2"; }

    package main;
    use Extender;
    my $object = TestObject7->new();
    ok($object->can('method1'), 'Object can method1 before Unload');
    ok($object->can('method2'), 'Object can method2 before Unload');

    Unload($object, 'method1');
    ok(!$object->can('method1'), 'Object cannot method1 after Unload');
    ok($object->can('method2'), 'Object can method2 after Unload');
}

# Test AddMethod function
{
    package TestObject8;
    sub new { bless {}, shift; }

    package main;
    use Extender;
    my $object = TestObject8->new();
    AddMethod($object, 'new_method', sub { return "New method"; });

    ok($object->can('new_method'), 'Object can new_method');
    is($object->new_method(), "New method", "Add new method");
}

# Test Decorate function with regular subroutine
{
    package TestObject10;
    sub new { bless {}, shift; }
    sub original_method { return "Original method" }

    package main;
    use Extender;
    my $object = TestObject10->new();
    Decorate($object, 'original_method', sub {
        my ($self, $original, @args) = @_;
        return "Before: " . $original->($self, @args) . " After";
    });

    is($object->original_method(), "Before: Original method After", "Decorate method");
}

# Test ApplyRole
{
    {
        package TestObject11;
        sub new { bless {}, shift; }
    }

    package main;
    use Extender;

    # Test 1: Successful application of role
    {
        my $object = TestObject11->new();
        my $result = ApplyRole($object, 'MockRole');
        ok($result, "ApplyRole successfully applied MockRole");
        ok($object->can('new_method'), 'Object can new_method after applying MockRole');
    }

    # Test 2: Role class not loaded
    {
        my $object = TestObject11->new();
        my $result = ApplyRole($object, 'NotExistingRole');
        ok(!$result, "ApplyRole should return undef for non-existing role");
        # You can add additional checks if needed
    }

    # Test 3: Role class does not implement apply method
    {
        my $object = TestObject11->new();
        my $result = ApplyRole($object, 'MockNoRole');
        ok(!$result, "ApplyRole should return undef for role without apply method");
        # You can add additional checks if needed
    }
}

# Test InitHook function
{
    package TestObject12;
    sub new {
        my $self = bless {}, shift;
        return $self;
    }

    sub DESTROY {
        my $self = shift;
        # Implement destruction logic if needed
    }

    package main;
    use Extender;

    # Function to capture standard output
    sub capture_stdout(&) {
        my $code = shift;
        open(my $stdout, '>', \my $capture) or die "Cannot redirect STDOUT: $!";
        my $stdout_original = *STDOUT;
        *STDOUT = $stdout;
        my $result = eval { $code->(); };
        *STDOUT = $stdout_original;
        close $stdout;
        return $capture;
    }

    # Test 1: Register INIT hook and verify it is called during object initialization
    {
        my $output = capture_stdout {
            # Register INIT hook
            InitHook('TestObject12', 'INIT', sub {
                print "Initializing object\n";
            });

            # Initialize object
            my $object = TestObject12->new();
        };

        like($output, qr/Initializing object/, "INIT hook called during object initialization");
    }

    # Test 2: Register DESTRUCT hook and verify it is called during object destruction
    {
        my $output = capture_stdout {
            # Register DESTRUCT hook
            InitHook('TestObject12', 'DESTRUCT', sub {
                print "Destructing object\n";
            });

            # Initialize and then destroy object
            my $object = TestObject12->new();
            undef $object;
        };

        like($output, qr/Destructing object/, "DESTRUCT hook called during object destruction");
    }
}

# Test GenerateMethod function
{
    package TestObject13;
    sub new { bless {}, shift; }

    package main;
    use Extender;
    my $object = TestObject13->new();
    my $arg1 = 'arg1';
    my $arg2 = 'arg2';

    GenerateMethod($object, 'dynamic_method', sub {
        my ($self, $arg1, $arg2) = @_;
        return "Dynamic method called with args: $arg1, $arg2";
    });

    ok($object->can('dynamic_method'), 'Object can dynamic_method');
    is($object->dynamic_method($arg1, $arg2), "Dynamic method called with args: $arg1, $arg2", "Generate method");
}

# Test MooseCompat
{
    # Test 1: MooseCompat - Successful application of Moose role
    {
        package TestObject14;
        sub new { bless {}, shift; }
    }

    package main;
    use Extender;

    # Test successful application of MockTestRole
    my $object1 = TestObject14->new();
    my $result1 = MooseCompat($object1, 'MockTestRole');
    ok($result1, "MooseCompat successfully applied MockTestRole");
    ok($object1->can('new_method'), 'Object can new_method after applying Moose role');

    # Test 2: MooseCompat - Role class not loaded
    ok(!MooseCompat(TestObject14->new(), 'NonExistentRole'), "MooseCompat undef when role class doesn't exist");

    # Test 3: MooseCompat - Role class does not implement apply method
    ok(!MooseCompat(TestObject14->new(), 'MockNoTestRole'), "MooseCompat undef when role class lacks apply method");
}

done_testing();
