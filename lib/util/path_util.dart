
class PathUtil {

  static String getParentPath(String path){
    return path.substring( 0, _lastSlashIndex(path) );
  }

  static String getLeafName(String path){
    return path.substring( _lastSlashIndex(path) + 1 );
  }

  static int _lastSlashIndex(String str){
    return str.lastIndexOf("\\");
  }

}
