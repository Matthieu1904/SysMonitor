# SysMonitor
Projet d'Application Shell de Gestion des Processus.

Outil shell avancé capable d'interagir avec /proc, d'afficher et gérer les informations sysètmes, les systèmes.

# Options:
- (par défaut)	Afficher un résumé des informations systèmes (CPU, RAM, uptime, etc.)
- -lp			Lister tous les processus en cours via /proc
- -s pid		Afficher les détails (nom, état, mémoire, etc.) du processus pid
- -lcpu			Afficher les informations CPU extraites de /proc/cpuinfo
- --save		Sauvegarder les informations systèmes pertinentes dans sysinfo.log
- -bg cmd		Lancer le programme cmd en arrière-plan
- -stop pid		Suspendre le processus pid
- -cont pid		Relancer le processus pid suspendu en arrière-plan
- -kill pid		Terminer le processus pid
- -h ou --help	Afficher l'aide du script avec des exemples
