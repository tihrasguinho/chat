enum Method {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  final String verb;

  const Method(this.verb);
}
