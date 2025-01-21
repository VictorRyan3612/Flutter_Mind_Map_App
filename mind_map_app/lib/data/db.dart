import 'package:mind_map_app/data/node.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB {
  DB._();
  static final DB instance = DB._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;  // Se o banco já está inicializado, retorna ele.
    _database = await _initDataBase();  // Caso contrário, inicializa o banco.
    return _database!;
  }

  // Abre ou cria o banco de dados
  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    return await _initDataBase();
  }

  // Método para salvar um novo MindMap no banco
  static Future<void> saveMindMap(MindMap mindMap) async {
  final db = await getDatabase();

  // Insere o mindMap e captura o id gerado
  int mindMapId = await db.insert(
    'mindmaps',
    mindMap.toDatabaseJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  // Agora insira os nodes e edges associados ao mindMap, passando o mindMapId para as inserções
  for (Node node in mindMap.nodes ?? []) {
    // Cria um mapa com os dados do node, incluindo o mindMapId
    var nodeJson = node.toJson();
    nodeJson['mindMapId'] = mindMapId;  // Adiciona o mindMapId ao JSON do node
    await db.insert('nodes', nodeJson, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  for (var edge in mindMap.edges ?? []) {
    // Cria um mapa com os dados do edge
    var edgeJson = edge.toJson();
    edgeJson['mindMapId'] = mindMapId;
    await db.insert('edges', edgeJson, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}



  // Método para carregar todos os MindMaps
  static Future<List<MindMap>> loadMindMaps() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('mindmaps');
    
    List<MindMap> mindMaps = [];
    
    for (var map in maps) {
      var mindMap = MindMap.fromjson(map);
      
      // Carrega os nodes associados ao mindMap
      var nodes = await db.query(
        'nodes', 
        where: 'mindMapId = ?', 
        whereArgs: [mindMap.id]
      );

      // Carrega as edges associadas ao mindMap
      var edges = await db.query(
        'edges', 
        where: 'mindMapId = ?', 
        whereArgs: [mindMap.id]
      );
      
      mindMap.nodes = nodes.map((nodeData) => Node.fromJson(nodeData)).toList();
      mindMap.edges = edges.map((edgeData) => Edge.fromJson(edgeData)).toList();
      
      mindMaps.add(mindMap);
    }

    return mindMaps;
  }


  
  // static String join(String s, String t) {}
  static _initDataBase() async{
    return await openDatabase(
      join(await getDatabasesPath(), 'mindmap.db'),
      version: 1,
      onCreate: _onCreate 
    );
  }
  static _onCreate (db, version) async{
    await db.execute(_createNodes);
    await db.execute(_createEdges);
    await db.execute(_createMindMap);
  }

  static String get _createNodes => '''
  CREATE TABLE nodes(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT,
    color INTEGER,
    positionDx REAL,
    positionDy REAL,
    width REAL,
    height REAL,
    mindMapId INTEGER,
    borderRadiusValue REAL,
    image TEXT,
    FOREIGN KEY (mindMapId) REFERENCES mindmaps(id)
  );
  ''';

  static String get _createEdges => '''
  CREATE TABLE edges(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idSource INTEGER,
    idDestination INTEGER,
    color INTEGER,
    size REAL,
    curvad INTEGER, -- Considerando como INTEGER para valores booleanos
    arrow INTEGER, -- Considerando como INTEGER para valores booleanos
    mindMapId INTEGER,
    FOREIGN KEY (mindMapId) REFERENCES mindmaps(id)
  );
  ''';

  static String get _createMindMap => '''
  CREATE TABLE mindmaps(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    weight INTEGER, -- Adicionando o campo 'weight'
    createdAt TEXT,
    modifiedAt TEXT
  );
  ''';

  insertNode(db, version, Node node)async{
    await db.insert('nodes', node.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  insertEdge(db, version, Edge edge)async{
    await db.insert('edges', edge.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  insertMindMap(db, version, MindMap mindMap) async{
    // mindMap.toJson();
    await db.insert('mindmaps', mindMap.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Outros métodos para editar, deletar, etc. podem ser adicionados aqui
}
