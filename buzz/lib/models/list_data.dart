class ListData {
  final String title;
  final List<Map<String, String>> items;

  ListData({required this.title, required this.items});
}

final List<ListData> listData = [
  ListData(
    title: 'Cadastro de Motorista',
    items: [
      {'primary': 'Pedro Henrique Mendes', 'secondary': '000.000.000-11'},
      {'primary': 'Maria Silva', 'secondary': '111.111.111-22'},
      // Adicione mais motoristas aqui
    ],
  ),
  ListData(
    title: 'Cadastro de Aluno',
    items: [
      {'primary': 'João Pereira', 'secondary': '222.222.222-33'},
      {'primary': 'Ana Costa', 'secondary': '333.333.333-44'},
      // Adicione mais alunos aqui
    ],
  ),
  ListData(
    title: 'Cadastro de Ônibus',
    items: [
      {'primary': 'João Pereira', 'secondary': '222.222.222-33'},
      {'primary': 'Ana Costa', 'secondary': '333.333.333-44'},
      // Adicione mais alunos aqui
    ],
  ),
  ListData(
    title: 'Cadastro de Pontos de Ônibus',
    items: [
      {'primary': 'João Pereira', 'secondary': '222.222.222-33'},
      {'primary': 'Ana Costa', 'secondary': '333.333.333-44'},
      // Adicione mais alunos aqui
    ],
  ),
  ListData(
    title: 'Cadastro de Faculdades',
    items: [
      {'primary': 'João Pereira', 'secondary': '222.222.222-33'},
      {'primary': 'Ana Costa', 'secondary': '333.333.333-44'},
      // Adicione mais alunos aqui
    ],
  ),
  // Adicione mais listas aqui (Ônibus, Ponto de Ônibus, etc.)
];
