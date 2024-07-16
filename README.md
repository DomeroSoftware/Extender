
# Extender

Extender is a Perl module that facilitates the dynamic extension of objects with methods from other modules or custom-defined subroutines. It allows you to enhance Perl objects—whether hash references, array references, or scalar references—with additional functionalities without altering their original definitions.

## Installation

To install `Extender`, use CPAN or CPAN Minus:

```bash
  cpan Extender
```
or
```bash
  cpanm Extender
```

Installation from GitHub
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

```bash
  make clean
  cd ..
  rm -rf ./Extender
```
This will clean the installation files from your disk after installation.

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

- Extend($object, $module, @methods):
  Extend the provided `$object` with methods exported by `$module`.

- Extends($object, %extend):
  Extend the provided `$object` with multiple methods specified in the `%extend` hash.

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
