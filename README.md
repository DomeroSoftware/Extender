# Extender

A Perl module that offers a wide range of functionalities to dynamically extend Perl objects with additional methods. This module is particularly useful when you want to enhance Perl objects without modifying their original definitions directly. Here's a summary and explanation of each function provided by the `Extender` module:

### Summary of Functions in `Extender` Perl Module:

1. **Extend**:
   - **Purpose**: Extends an object with methods from a specified module.
   - **Usage**: `Extend($object, $module, @methods)`
   - **Example**: `Extend($object, 'Some::Module', 'method1', 'method2')`

2. **Extends**:
   - **Purpose**: Extends an object with custom methods defined by the user.
   - **Usage**: `Extends($object, %extend)`
   - **Example**: `Extends($object, custom_method => sub { ... }, another_method => \&some_function)`

3. **Alias**:
   - **Purpose**: Creates an alias for an existing method in the object with a new name.
   - **Usage**: `Alias($object, $existing_method, $new_name)`
   - **Example**: `Alias($object, 'existing_method', 'new_alias')`

4. **AddMethod**:
   - **Purpose**: Adds a new method to the object.
   - **Usage**: `AddMethod($object, $method_name, $code_ref)`
   - **Example**: `AddMethod($object, 'new_method', sub { ... })`

5. **Decorate**:
   - **Purpose**: Decorates an existing method with a custom decorator.
   - **Usage**: `Decorate($object, $method_name, $decorator)`
   - **Example**: `Decorate($object, 'method_to_decorate', sub { ... })`

6. **ApplyRole**:
   - **Purpose**: Applies a role (mixin) to an object.
   - **Usage**: `ApplyRole($object, $role_class)`
   - **Example**: `ApplyRole($object, 'SomeRole')`

7. **InitHook**:
   - **Purpose**: Adds initialization or destruction hooks to an object.
   - **Usage**: `InitHook($object, $hook_name, $hook_code)`
   - **Example**: `InitHook($object, 'INIT', sub { ... })`

8. **Unload**:
   - **Purpose**: Removes specified methods from the object's namespace.
   - **Usage**: `Unload($object, @methods)`
   - **Example**: `Unload($object, 'method1', 'method2')`

Compared to existing CPAN modules, Extender offers a competitive set of dynamic functionalities suitable for extending Perl objects with methods, applying roles, and managing object lifecycle events. It strikes a balance between simplicity and flexibility, making it suitable for various types of reference objects that require dynamic method management and behavior extension. Depending on specific needs and preferences, developers can choose between Extender and other modules based on the level of features, performance, and complexity required for their projects.

### Explanation and Usage:

- **Extend**: Useful for importing methods from external modules dynamically. It checks if the module is loaded, imports specified methods, and adds them to the object.
```perl
my $object = SomeClass->new();
Extend($object, 'SomeModule', 'method1', 'method2');

# Now $object has 'method1' and 'method2' imported from 'SomeModule'

Extend($object, 'OtherModule');

# Now $object has all EXPORT methods imported from 'OtherModule'
```
  
- **Extends**: Allows adding custom methods directly to an object. You can define methods inline using anonymous subroutines or reference existing functions.
```perl
my $object = SomeClass->new();
Extends($object, {
    custom_method => sub {
        my ($self, $arg) = @_;
        # Custom method implementation
    },
    another_method => \&existing_function,
});

# Now $object has 'custom_method' and 'another_method' added to it
```

- **Alias**: Creates an alias for an existing method. This alias allows using multiple names for the same underlying method implementation.
```perl
Alias($object,'existing_method', 'alias_method');
```

- **AddMethod**: Adds a new method to the object. This is useful when you want to dynamically extend an object's capabilities during runtime.
```perl
AddMethod($object,'new_method_name', sub {
    my ($self, $arg) = @_;
    # Method implementation
});
```

- **Decorate**: Decorates an existing method with custom behavior. It allows modifying the behavior of a method without directly altering its original implementation.
```perl
my $object = SomeClass->new();

# Define the decorator subroutine
my $decorator_sub = sub {
    my ($orig_method, $self, $arg) = @_;
    # Before calling the original method
    print "Before calling $method_name\n";
    $self->$orig_method($arg);  # Call the original method
    # After calling the original method
    print "After calling $method_name\n";
};

# Apply the decorator to the object's method
Decorate($object, 'existing_method', $decorator_sub);

# Now, calling $object->existing_method($arg) will invoke the decorated behavior
```

- **ApplyRole**: Applies a role (mixin) to an object, importing and applying its methods. This is useful for adding predefined sets of behavior to objects.
```perl
my $object = SomeClass->new();
ApplyRole($object, 'SomeRole');

# Now $object has methods from 'SomeRole'
```

- **InitHook**: Adds hooks that execute during object initialization or destruction phases. This allows injecting custom logic into object lifecycle events.
```perl
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
```

- **Unload**: Removes specified methods from the object. This can be useful for cleaning up unnecessary methods or dynamically managing object behaviors.
```perl
Unload($object,'method_to_remove');
```

Each function in the `Extender` module provides powerful tools for dynamically managing and extending Perl objects, enhancing flexibility and maintainability in your Perl projects.

## Installation

To install `Extender`, use CPAN or CPAN Minus:

```bash
cpan Extender
```
or
```bash
cpanm Extender
```

### Installation from GitHub

To install Extender directly from GitHub, you can clone the repository and use the Makefile.PL:

```bash
git clone https://github.com/DomeroSoftware/Extender.git
cd Extender
perl Makefile.PL
make
make test
make install
```

This will clone the repository, generate the Makefile, build the module, run the tests, and install it on your system.

To clean the installation files from your disk after installation:

```bash
make clean
cd ..
rm -rf ./Extender
```

## Usage

### Extend an Object with Methods from a Module

```perl
use Extender;

# Example: Extend an object with methods from a module
my $object = MyClass->new();
Extend($object, 'Some::Class');

# Now $object can use any method from Some::Class
$object->method1(1, 2, 3, 4);
```

### Extend an Object with Custom Methods

```perl
use Extender;

# Example: Extend an object with custom methods
my $object = MyClass->new();
Extends($object,
    greet => sub { my ($self, $name) = @_; print "Hello, $name!\n"; },
    custom_method => \&some_function,
);

# Using the added methods
$object->greet('Alice');               # Output: Hello, Alice!
$object->custom_method('Hello');       # Assuming some_function prints something
```

### Adding Methods to Raw Reference Variables

```perl
use Extender;

# Example 1: Hash reference
my $hash_object = {};
my @methods_for_hash = ('set_value', 'get_value');
Extend($hash_object, 'HashMethods', @methods_for_hash);
$hash_object->set_value('key', 'value');
print $hash_object->get_value('key'), "\n";  # Outputs: value

# Example 2: Array reference
my $array_object = [];
my @methods_for_array = ('add_item', 'get_item');
Extend($array_object, 'ArrayMethods', @methods_for_array);
$array_object->add_item('item1');
$array_object->add_item('item2');
print $array_object->get_item(0), "\n";  # Outputs: item1

# Example 3: Scalar reference with custom methods

# Scalar variable
my $scalar = "hello";

# Creating a reference to $scalar
my $scalar_ref = \$scalar;

# Defining custom methods for scalar manipulation
Extends($scalar_ref,
    capitalize => sub {
        my $self = shift;
        $$self = ucfirst $$self;  # Capitalize the string
        return $self
    },
    append_text => sub {
        my ($self, $text) = @_;
        $$self .= $text;  # Append text to the string
        return $self
    }
);

# Applying custom methods to manipulate the scalar via its reference
$scalar_ref->capitalize->append_text(", Perl!");

# Dereferencing and printing the manipulated scalar
print $$scalar_ref, "\n";  # Outputs: Hello, Perl!
```

## Exported Functions

- **Extend(\$object, $module, @methods)**:
  Extend the provided `$object` with methods exported by `$module`.

- **Extends(\$object, %extend)**:
  Extend the provided `$object` with multiple methods specified in the `%extend` hash.

- **Alias(\$object, $alias_name, $original_method_name)**:
  Create an alias `$alias_name` for the `$original_method_name` on `$object`.

- **AddMethod(\$object, $method_name, $method_code)**:
  Add a new method `$method_name` with `$method_code` to the `$object`.

- **Decorate(\$object, $method_name, $decorator_code)**:
  Decorate the `$method_name` of `$object` using the `$decorator_code`.

- **ApplyRole(\$object, $role_class)**:
  Apply the Moose role `$role_class` to the `$object`.

- **InitHook(\$object, $hook_name, $hook_code)**:
  Register `$hook_code` to be executed at `$hook_name` (INIT or DESTRUCT) for `$object`.

- **Unload(\$object, @methods)**:
  Remove specified methods from the `$object`.

## Author

OnEhIppY @ Domero Software  
Email: domerosoftware@gmail.com  
GitHub: [DomeroSoftware/Extender](https://github.com/DomeroSoftware/Extender)

## License

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See [perlartistic](https://dev.perl.org/licenses/artistic.html) and [perlgpl](https://dev.perl.org/licenses/gpl-1.0.html).

## See Also

- [Exporter](https://metacpan.org/pod/Exporter)
- [perlfunc](https://metacpan.org/pod/perlfunc)
- [perlref](https://metacpan.org/pod/perlref)
- [perlsub](https://metacpan.org/pod/perlsub)
