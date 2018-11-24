
.PHONY: all clean test robots nerell elfa

clean:
	rm -Rf .mnt
	rm -Rf .tmp

test:
	echo "Not yet implemented"

encrypt:
	ansible-vault encrypt --vault-password-file=.vault_password vars/*.vault.*

decrypt:
	ansible-vault decrypt --vault-password-file=.vault_password vars/*.vault.*

sd_card:
	ansible-playbook 01_prepare_sd.yml -K --vault-password-file=.vault_password

all: robots

robots: nerell elfa

nerell:
	ansible-playbook 02_nerell.yml

elfa:
	ansible-playbook 03_elfa.yml
