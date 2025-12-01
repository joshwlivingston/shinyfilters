# Filter Input Catalog

## Contents

Return Types:

- [`dateInput`](#dateinput)
- [`dateRangeInput`](#daterangeinput)
- [`numericInput`](#numericinput)
- [`radioButtons`](#radiobuttons)
- [`selectInput`](#selectinput)
- [`selectizeInput`](#selectizeinput)
- [`sliderInput`](#sliderinput)
- [`textAreaInput`](#textAreainput)
- [`textInput`](#textinput)

Input Types:

- [character](#character-5)
- [Date](#date-2)
- [factor](#factor-3)
- [list](#list-3)
- [numeric](#numeric-2)
- [POSIXt](#posixt-2)

## Return Types

### `dateInput`

#### Date

``` r
filterInput(
    x = Sys.Date() + 0:9,
    inputId = "id",
    label = "Pick a date:"
)
```

  

#### POSIXt

``` r
filterInput(
    x = Sys.time() + as.difftime(0:9, units = "days"),
    inputId = "id",
    label = "Pick a date:"
)
```

  
  

### `dateRangeInput`

#### Date

- `range = TRUE`

``` r
filterInput(
    x = Sys.Date() + 0:9,
    inputId = "id",
    label = "Pick a date range:",
    range = TRUE
)
```

  

#### POSIXt

- `range = TRUE`

``` r
filterInput(
    x = Sys.time() + as.difftime(0:9, units = "days"),
    inputId = "id",
    label = "Pick a date range:",
    range = TRUE
)
```

  
  

### `numericInput`

#### numeric

``` r
filterInput(
    x = 0:9,
    inputId = "id",
    label = "Pick a number:"
)
```

Pick a number:

  
  

### `radioButtons`

#### character

- `radio = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Pick a letter:",
    inline = TRUE,
    radio = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### factor

- `radio = TRUE`

``` r
filterInput(
    x = as.factor(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    inline = TRUE,
    radio = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### list

- `radio = TRUE`

``` r
filterInput(
    x = as.list(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    inline = TRUE,
    radio = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  
  

### `selectInput`

#### character

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Pick a letter:"
)
```

Pick a letter:

a b c d e f g h i j

  

#### factor

``` r
filterInput(
    x = as.factor(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:"
)
```

Pick a letter:

a b c d e f g h i j

  

#### list

``` r
filterInput(
    x = as.list(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:"
)
```

Pick a letter:

a b c d e f g h i j

  
  

### `selectizeInput`

#### character

- `selectize = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Pick a letter:",
    selectize = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### factor

- `selectize = TRUE`

``` r
filterInput(
    x = as.factor(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    selectize = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### list

- `selectize = TRUE`

``` r
filterInput(
    x = as.list(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    selectize = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  
  

### `sliderInput`

#### numeric

- `slider = TRUE`

``` r
filterInput(
    x = 0:9,
    inputId = "id",
    label = "Pick a number:",
    slider = TRUE
)
```

  
  

### `textAreaInput`

#### character

- `textbox = TRUE`
- `area = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Type many letters[1:10]:",
    textbox = TRUE,
    area = TRUE
)
```

Type many letters\[1:10\]:

  
  

### `textInput`

#### character

- `text = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Type a letter:",
    textbox = TRUE
)
```

Type a letter:

  

## Input Types

  

### character

#### `selectInput`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Pick a letter:"
)
```

Pick a letter:

a b c d e f g h i j

  

#### `selectizeInput`

- `selectize = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Pick a letter:",
    selectize = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### `radioButtons`

- `radio = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Pick a letter:",
    inline = TRUE,
    radio = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### `textInput`

- `textbox = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Type a letter:",
    textbox = TRUE
)
```

Type a letter:

  

#### `textAreaInput`

- `textbox = TRUE`
- `area = TRUE`

``` r
filterInput(
    x = letters[1:10],
    inputId = "id",
    label = "Type many letters[1:10]:",
    textbox = TRUE,
    area = TRUE
)
```

Type many letters\[1:10\]:

  
  

### Date

#### `dateInput`

``` r
filterInput(
    x = Sys.Date() + 0:9,
    inputId = "id",
    label = "Pick a date:"
)
```

  

#### `dateRangeInput`

- `range = TRUE`

``` r
filterInput(
    x = Sys.Date() + 0:9,
    inputId = "id",
    label = "Pick a date range:",
    range = TRUE
)
```

  
  

### factor

#### `selectInput`

``` r
filterInput(
    x = as.factor(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:"
)
```

Pick a letter:

a b c d e f g h i j

  

#### `selectizeInput`

- `selectize = TRUE`

``` r
filterInput(
    x = as.factor(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    selectize = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### `radioButtons`

- `radio = TRUE`

``` r
filterInput(
    x = as.factor(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    inline = TRUE,
    radio = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  
  

### list

#### `selectInput`

``` r
filterInput(
    x = as.list(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:"
)
```

Pick a letter:

a b c d e f g h i j

  

#### `selectizeInput`

- `selectize = TRUE`

``` r
filterInput(
    x = as.list(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    selectize = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  

#### `radioButtons`

- `radio = TRUE`

``` r
filterInput(
    x = as.list(letters[1:10]),
    inputId = "id",
    label = "Pick a letter:",
    inline = TRUE,
    radio = TRUE
)
```

Pick a letter:

a b c d e f g h i j

  
  

### numeric

#### `numericInput`

``` r
filterInput(
    x = 0:9,
    inputId = "id",
    label = "Pick a number:"
)
```

Pick a number:

  

#### `sliderInput`

- `slider = TRUE`

``` r
filterInput(
    x = 0:9,
    inputId = "id",
    label = "Pick a number:",
    slider = TRUE
)
```

  
  

### POSIXt

#### `dateInput`

``` r
filterInput(
    x = Sys.time() + as.difftime(0:9, units = "days"),
    inputId = "Id",
    label = "Pick a date:"
)
```

  

#### `dateRangeInput`

- `range = TRUE`

``` r
filterInput(
    x = Sys.time() + as.difftime(0:9, units = "days"),
    inputId = "Id",
    label = "Pick a date range:",
    range = TRUE
)
```

  
