class BackendUrls {
  static final BackendUrls _instance = BackendUrls._internal();

  // Private constructor
  BackendUrls._internal();

  // Factory constructor to return the singleton instance
  factory BackendUrls() {
    return _instance;
  }

  String httpBase = 'http://192.168.100.3:8080/PI_Backend/';
  
  String getLogin() {
    return '$httpBase' + 'login';
  }

  String getPessoa() {
    return '$httpBase' + 'pessoa';
  }
  String getPessoaCPF(String cpf){
    return '$httpBase' + 'pessoa/$cpf';
  }

  String getFuncionario() {
    return '$httpBase' + 'funcionario';
  }
  String getCadastrarFuncionario(){
    return  getFuncionario() + '/cadastrar';
  }
  String getOrdem(){
    return  '$httpBase' + 'ordem';
  }
  String getCadastrarOrdemAtendente(){
    return getOrdem() + '/cadastroPorAtendente';
  }
  String getCadastrarOrdemTecnico(){
     return getOrdem() + '/cadastroPorTecnico';
  }
}
