
.PHONY: all clean test robots nerell odin tinker

clean:
	rm -Rf .mnt
	rm -Rf .tmp

test:
	echo "Not yet implemented"

encrypt:
	find . -type f -name *.vault.* -exec ansible-vault encrypt '{}' \;

decrypt:
	find . -type f -name *.vault.* -exec ansible-vault decrypt '{}' \;

sd_card:
	ansible-playbook 01_prepare_sd.yaml -K

all: robots

robots: nerell odin

nerell:
	ansible-playbook 02_nerell.yaml

odin:
	ansible-playbook 02_odin.yaml

tinker:
	ansible-playbook 02_tinker.yaml

list-hosts:
	ansible-inventory --list
