#!/bin/bash

# Solicitar o nome base do grupo
read -p "Digite o nome base do grupo: " GROUP_BASE

# Solicitar a quantidade de grupos a serem criados
while true; do
  read -p "Digite a quantidade de grupos a serem criados: " NUM_GROUPS
  if [[ $NUM_GROUPS =~ ^[0-9]+$ ]]; then
    break
  else
    echo "Por favor, insira um número válido."
  fi
done

# Criar grupos, usuários e pools com números sequenciais
for i in $(seq -w 01 $NUM_GROUPS); do
  GROUP_NAME="${GROUP_BASE}${i}"
  USER_NAME="${GROUP_BASE}${i}"
  FIRST_NAME="${GROUP_BASE}"
  LAST_NAME="${i}"
  PASSWORD="${USER_NAME}"
  REALM="pve"
  POOL_NAME="${GROUP_BASE}${i}"

  # Criar grupo
  pveum groupadd $GROUP_NAME
  echo "Grupo $GROUP_NAME criado com sucesso."

  # Criar usuário
  pveum useradd ${USER_NAME}@${REALM} -firstname $FIRST_NAME -lastname $LAST_NAME -password $PASSWORD
  echo "Usuário ${USER_NAME}@${REALM} criado com sucesso."

  # Adicionar usuário ao grupo
  pveum usermod ${USER_NAME}@${REALM} -group $GROUP_NAME
  echo "Usuário ${USER_NAME}@${REALM} adicionado ao grupo $GROUP_NAME com sucesso."

  # Criar pool
  pvesh create /pools -poolid $POOL_NAME
  echo "Pool $POOL_NAME criado com sucesso."

  # Configurar permissões
  pveum aclmod /pool/$POOL_NAME -group $GROUP_NAME -role Administrator -propagate 1
  echo "Permissões configuradas para o pool $POOL_NAME com o grupo $GROUP_NAME."
done
