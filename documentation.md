## How to use DB.dart

### Insert
The following code inserts data (use Map data type for best results) at the specified location in Firebase.  
**`DB.insert(<location>, <data>);`**
```dart
DB.insert(DB.db().reference().child("user").child("Kelvin"), {"name": "Kelvin", "pp": "small"});
```

### Retrieve
This code returns the data from the specified location as a Future<dynamic>. Future is a data type for asynchronous programming.  
**`DB.get(<location>);`**
```dart
DB.get(DB.db().reference().child("user").child("Kelvin").then((var value){
    print(value["name"]); //Prints 'Kelvin'
  });
```

### Delete
This code removes **EVERY** child at the specified location in Firebase.  
**`DB.remove(<location>);`**
```dart
DB.remove(DB.db().reference().child("user").child("Kelvin"));
```
