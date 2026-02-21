import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Serviço de persistência local usando arquivos JSON.
/// Responsável por salvar e carregar dados no armazenamento do dispositivo.
/// Utiliza o diretório de documentos do app para garantir persistência dos dados.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Obtém o caminho do diretório de armazenamento local do aplicativo.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Retorna a referência do arquivo JSON com base no nome fornecido.
  Future<File> _getFile(String filename) async {
    final path = await _localPath;
    return File(p.join(path, '$filename.json'));
  }

  /// Salva uma lista de objetos serializáveis em um arquivo JSON local.
  /// [filename] - Nome do arquivo (sem extensão)
  /// [data] - Lista de Maps representando os objetos a serem salvos
  Future<void> saveList(
    String filename,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final file = await _getFile(filename);
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      // Em caso de erro na escrita, loga mas não interrompe o app
      print('Erro ao salvar dados localmente: $e');
    }
  }

  /// Carrega uma lista de objetos de um arquivo JSON local.
  /// Retorna uma lista vazia caso o arquivo não exista ou haja erro de leitura.
  Future<List<Map<String, dynamic>>> loadList(String filename) async {
    try {
      final file = await _getFile(filename);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Erro ao carregar dados locais: $e');
    }
    return [];
  }

  /// Salva um único objeto (Map) em um arquivo JSON local.
  /// Usado para dados simples como configurações ou credenciais.
  Future<void> saveMap(String filename, Map<String, dynamic> data) async {
    try {
      final file = await _getFile(filename);
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Erro ao salvar dados: $e');
    }
  }

  /// Carrega um único objeto (Map) de um arquivo JSON local.
  /// Retorna null caso o arquivo não exista.
  Future<Map<String, dynamic>?> loadMap(String filename) async {
    try {
      final file = await _getFile(filename);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
    return null;
  }

  /// Remove um arquivo de dados local.
  Future<void> delete(String filename) async {
    try {
      final file = await _getFile(filename);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erro ao deletar arquivo: $e');
    }
  }
}
