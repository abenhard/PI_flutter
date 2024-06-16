class BackendUrls {
  static final BackendUrls _instance = BackendUrls._internal();

  // Private constructor
  BackendUrls._internal();

  // Factory constructor to return the singleton instance
  factory BackendUrls() {
    return _instance;
  }

  String httpBase =  'http://192.168.100.3:8080/PI_Backend/';
  
  String getLogin() {
    return '$httpBase' + 'login';
  }

  String getPessoas() {
    return '$httpBase' + 'pessoa';
  }
  String getPessoaCPF(String cpf){
    return '$httpBase' + 'pessoa/$cpf';
  }
  String updatePessoa(){
    return getPessoas();
  }
  String getFuncionario() {
    return '$httpBase' + 'funcionario';
  }
  String getTecnicos(){
     return '$httpBase' + 'funcionario/tecnicos';
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
  String getOrdemServicoTecnico()
  {
     return getOrdem() + '/funcionario/tecnico';
  }
  String postOrdemServicoAtendente()
  {
    return getOrdem() +'/cadastroPorAtendente';
  }
  String postOrdemServicoTecnico()
  {
    return getOrdem() +'/cadastroPorTecnico';
  }
  String updateOrdemServicoTecnico(){
    return getOrdem() + '/alterarOrdem';
  }

  String deleteImage() {
    return getOrdem() + '/images';
  }

  String ordemServicoDetalhes(ordem) {
    return getOrdem() + '';
  }

  String getOrdemServicoImagens(ordem) {
    return getOrdem() +  '/{$ordem}/images';
  }
}
