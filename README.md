# 💊 Medical Pharmacy

Aplicação móvel desenvolvida em Flutter para gestão de medicamentos e beneficiários, com integração Firebase.

##  Sobre o Projeto

O Medical Pharmacy é um MVP desenvolvido no âmbito do Trabalho Prático 2, que permite gerir doações de medicamentos, cadastrar beneficiários e atribuir tarefas a operadores.

##  Perfis de Utilizador

| Perfil | Permissões |
|--------|-----------|
| **Administrador** | Acesso total — gere utilizadores, medicamentos, beneficiários e tarefas |
| **Operador** | Gere medicamentos, beneficiários e tarefas |
| **Doador** | Apenas regista medicamentos |

##  Funcionalidades

-  Autenticação com Firebase Auth
-  Registo e login de utilizadores
-  Permissões por perfil
-  Registo de medicamentos com controlo de validade
-  Cadastro de beneficiários
-  Gestão de tarefas (pendente, em progresso, concluída)
-  Gestão de utilizadores (admin)
-  Dados em tempo real com Firestore

## ️ Tecnologias

- Flutter 3.x
- Firebase Authentication
- Cloud Firestore
- Provider (gestão de estado)

##  Estrutura do Projeto

##  Como Correr

1. Clona o repositório
```bash
git clone https://github.com/FranciscoVembane/medical_pharmacy.git
```

2. Instala as dependências
```bash
flutter pub get
```

3. Corre a app
```bash
flutter run
```

## Equipa

Desenvolvido pelo grupo — ISUTC, 2026.