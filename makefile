all : clean


clean:
	-(! (ps -elf|pgrep nr-ue)) ||sudo kill -9 $$(ps -elf|pgrep nr-ue)
	-(! (ps -elf|pgrep nr-gnb)) ||sudo kill -9 $$(ps -elf|pgrep nr-gnb)
	-(! (ps -elf|pgrep nr-binder)) ||sudo kill -9 $$(ps -elf|pgrep nr-binder)
	-(! (pgrep -f UE.py)) ||sudo kill -9 $$(pgrep -f UE.py)

delete:
	-(! (ps -elf|pgrep nr-ue)) ||sudo kill -9 $$(ps -elf|pgrep nr-ue)
	-(! (ps -elf|pgrep nr-gnb)) ||sudo kill -9 $$(ps -elf|pgrep nr-gnb)
	-(! (ps -elf|pgrep nr-binder)) ||sudo kill -9 $$(ps -elf|pgrep nr-binder)
	-(! (pgrep -f UE.py)) ||sudo kill -9 $$(pgrep -f UE.py)
	-(! (kubectl get namespaces -o custom-columns=":metadata.name"|grep oai)) ||kubectl delete ns $$(kubectl get namespaces -o custom-columns=":metadata.name"|grep oai)
	-(! (pgrep -f sim.py)) ||sudo kill -9 $$(pgrep -f sim.py)
