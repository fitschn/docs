#!/bin/bash

# Based on official example from https://developer.hashicorp.com/vault/docs/commands/token-helper

function write_error(){ >&2 echo $@; }

function createHashKey {

  local key=""

  if [[ -z "${1}" ]] ; then key="${VAULT_ADDR}"
  else                      key="${1}"
  fi

  # We index the token according to the Vault server address by default so
  # return an error if the address is empty
  if [[ -z "${key}" ]] ; then
    write_error "Error: VAULT_ADDR environment variable unset."
    exit 100
  fi

  key=${key//http:\/\//""}
  key=${key//https:\/\//""}
  key=${key//"."/"_"}
  key=${key//":"/"_"}

  echo "addr-${key}"
}

KEY=$(createHashKey)
TOKEN="null"

case "${1}" in
    "get")

      # Get token from keychain
      TOKEN=$(security find-generic-password -w -s "vault-token" -a "vault-cli/${KEY}" 2> /dev/null)

      if [ ! "${TOKEN}" == "" ] ; then
        echo -n "${TOKEN}"
      fi
      exit 0
    ;;

    "store")

      # Get the token from stdin
      read TOKEN

      # Write token to keychain
      security add-generic-password -U -s "vault-token" -a "vault-cli/${KEY}" -w "${TOKEN}" > /dev/null 2>&1
      exit 0
    ;;

    "erase")
      security delete-generic-password -s "vault-token" -a "vault-cli/${KEY}" > /dev/null 2>&1
      exit 0
    ;;

    *)
      # change to stderr for real code
      write_error "Error: Provide a valid command: get, store, or erase."
      exit 101
esac
