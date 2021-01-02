import 'package:hive/hive.dart';
import 'package:id_mvc_app_framework/utils/storage/storage_service.dart';

class HiveStorageService<T> extends StorageServiceBase<T> {
  String _boxName;
  String _defaultKey;
  Box<T> _box;
  T _data;
  Iterable<String> _allKeys;

  // constructor with default box name
  HiveStorageService(String boxName, {String defaultKey = 'default'})
      : assert(boxName != null),
        _boxName = boxName,
        _defaultKey = 'default',
        super();

  // Closing the hive box
  @override
  void dispose() async {
    assert(isLoaded, 'Box $_boxName has to be loaded first');
    await _box.close();
  }
  // Checking the open status
  @override
  bool get isLoaded => _box != null;

  // To match StorageServiceBase
  @override
  Future<T> load() async {
    return await loadWithKey(_defaultKey);
  }

  @override
  Future<void> save() async {
    await saveWithKey(_defaultKey);
  }
  // Main save/load wrappers
  Future<void> saveWithKey(String key) async {
    assert(isLoaded, 'Box $_boxName has to be loaded first');
    await _box.put(key, _data);
  }

  Future<T> loadWithKey(String key) async {
    _box = await getOpenBox();
    return _box.get(key);
  }

  static Future<HiveStorageService<String>> openAndLoadJsonBox(String boxName) async{
    var storage = HiveStorageService<String>(boxName);
    if (!storage.isLoaded) await storage.load();
    return storage;
  }

  // Getter/setter for data
  @override
  T get data => _data;

  @override
  set data(T value) => _data = value;

  // List of keys for iterating through them
  List<dynamic> get allKeys => (isLoaded ? _box.keys.toList() : 0);

  // To prevent opening new box every time
  Future<Box<T>> getOpenBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  // Checking if item is present in the box
  bool contains(String key) => (isLoaded ? _box.containsKey(key) : false);
}