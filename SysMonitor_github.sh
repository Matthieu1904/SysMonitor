#!/bin/bash

# SysMonitor.sh
# Développeurs: Aicha MENDY, Lucas LEGAZ et Matthieu SAUVAGEOT

# Application Shell de Gestion des Processus

# Objectif: Concevoir un outil shell avancé capable d'interagir avec /proc, d'afficher et gérer les informations sysètmes, les systèmes

# Options:
#	- (par défaut)	Afficher un résumé des informations systèmes (CPU, RAM, uptime, etc.)
#	- -lp			Lister tous les processus en cours via /proc
#	- -s pid		Afficher les détails (nom, état, mémoire, etc.) du processus pid
#	- -lcpu			Afficher les informations CPU extraites de /proc/cpuinfo
#	- --save		Sauvegarder les informations systèmes pertinentes dans sysinfo.log
#	- -bg cmd		Lancer le programme cmd en arrière-plan
#	- -stop pid		Suspendre le processus pid
#	- -cont pid		Relancer le processus pid suspendu en arrière-plan
#	- -kill pid		Terminer le processus pid
#	- -h ou --help	Afficher l'aide du script avec des exemples

export LC_ALL=C.UTF-8 # pour assurer un affichage propre avec les emojis.

# Initialiser le fichier de log d'exécution
logfile="sysinfo.txt"
echo "=== Résultat d'exécution - $(date) ===" > "$logfile"
echo "" >> "$logfile"


# Fonction pour Afficher un résumé des infos système (CPU, RAM, uptime, etc.)
cpu_info() {
    echo "./SysMonitor.sh" >> "$logfile"
    {
        echo "======= INFORMATIONS SYSTEME ======="
        echo ""
        echo "Système d'exploitation : $(uname -o -p)"
        echo "Nom de la machine       : $(hostname)"
        echo "Uptime                  : $(uptime)"
        echo "RAM utilisée / totale   : $(free -h | grep 'Mem' | awk '{print $3 "/" $2}')"
        echo "Nom du CPU              : $(grep 'model name' /proc/cpuinfo | head -n1 | awk '{for(i=4;i<=NF;i++) printf $i " "; print ""}')"
    } | tee -a "$logfile"  # Affiche à l'écran ET enregistre dans le fichier log (sysLog.txt)
}


# Fonction pour Lister tous les processus en cours via /proc (option -lp)
list_processes(){
	echo "./SysMonitor.sh -lp" >> "$logfile"
	{
		# Titre de section
		echo "=== Liste des processus en cours ==="

		# En-têtes de colonnes : PID, nom du processus, état
		printf "%-10s %-25s %-10s\n" "PID" "Nom" "État"
		echo "-----------------------------------------------"

		# Boucle sur tous les dossiers numériques de /proc (correspondant aux PIDs)
		for pid in /proc/[0-9]*; do
			# Vérifie que le fichier status existe (donc qu'il s'agit bien d'un processus)
			if [ -f "$pid/status" ]; then
				# Récupère le PID depuis le nom du dossier
				PID=$(basename "$pid")

				# Extrait le nom du processus depuis le fichier status
				NOM=$(grep -s "^Name:" "$pid/status" | awk '{print $2}')

				# Extrait l'état du processus (R = en cours, S = en veille, Z = zombie, etc.)
				ETAT=$(grep -s "^State:" "$pid/status" | awk '{print $2}')

				# Affiche les informations du processus formatées proprement
				printf "%-10s %-25s %-10s\n" "$PID" "$NOM" "$ETAT"
			fi
		done

		echo "" # Saut de ligne
	} | tee -a "$logfile"  # Affiche à l'écran ET enregistre dans le fichier log (sysLog.txt)
}

# Fonction pour Afficher les détails (nom, état, mémoire, etc.) du processus pid (option -s pid)
process_details(){
	pid_saisi=$1
	if [[ -z $pid_saisi ]] #si pas d'argument mis dans la fonction (pid non saisi)
	then	echo "Vous n'avez pas saisi de pid." | tee -a "$logfile"
	return 1	
	fi

	#Verification de l'existance du PID	
	echo -n "PID saisi: " | tee -a "$logfile"
	ps aux | awk '{print $2}' | grep ^${pid_saisi}$ | tee -a "$logfile"
		
	echo -e "\n======= Détails sur le PID $pid_saisi =======\n" | tee -a "$logfile"
	retour=$?
	
	if [[ $retour -eq 0 ]]
	then	ps -q "$pid_saisi" -o comm=NOM -o %mem="%MEM" -o stat="Statut" 2>&1 | tee -a "$logfile"

	else	echo "Le PID n'existe pas" | tee -a "$logfile"
	fi
}

# Fonction pour afficher les informations CPU extraites de /proc/cpuinfo (option -lcpu)
infos_cpu() {
	# Trace l'utilisation de l'option -lcpu dans le fichier de log
	echo "./SysMonitor.sh -lcpu" >> "$logfile"

	{
		# Titre avec emoji pour le fun 😄
		echo "🧠 === Informations CPU ==="

		# Récupère et affiche le modèle de processeur (ex: Intel(R) Core(TM) i7...)
		modele=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
		echo "📌 Modèle        : $modele"

		# Récupère et affiche la fréquence actuelle du CPU en MHz
		frequence=$(grep -m1 "cpu MHz" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
		echo "🎚️ Fréquence     : $frequence MHz"

		# Compte le nombre total de cœurs logiques présents (threads)
		coeurs_logiques=$(grep -c ^processor /proc/cpuinfo)
		echo "🧩 Cœurs Logiques: $coeurs_logiques"

		# Récupère la taille du cache L2 du CPU
		cache=$(grep -m1 "cache size" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
		echo "🗃️ Cache         : $cache"

		# Récupère l'architecture système (x86_64, i686, etc.)
		arch=$(uname -m)
		echo "🏗️ Architecture  : $arch"

		echo ""  # Saut de ligne
	} | tee -a "$logfile"  # Affiche à l'écran et sauvegarde dans le fichier log
}

# Fonction pour Sauvegarder les informations système pertinentes dans sysinfo.log (option --save)
save_system_info(){
    echo "./SysMonitor.sh --save" >> "$logfile"

    cat <<EOF > "sysinfo.log"  # La redirection doit être placée ici, dès l'ouverture du here-document
[----- Informations Système -----]
Date : $(date)
Nom de la machine : $(hostname)
Noyau : $(uname -r)
Uptime : $(uptime)

[----- Utilisateurs connectés -----]
$(who)

[----- Espace Disque -----]
$(df -h)

[----- Mémoire -----]
$(free -h)
EOF

    # Détails des fonctions utilisées dans le programme :
    # date : Affiche la date et l'heure du système.
    # hostname : Récupère le nom de l'hôte.
    # uname -r : Affiche la version du noyau Linux.
    # uptime : Affiche depuis combien de temps la machine est allumée.
    # who : Affiche les utilisateurs actuellement connectés.
    # df -h : Affiche l'espace disque utilisé et disponible.
    # free -h : Affiche la mémoire vive utilisée/disponible en format lisible.
    echo "📁 Informations systèmes sauvegardées dans le fichier sysinfo.log."|tee -a "$logfile"
}

# Fonction pour lancer le programme cmd en arrière-plan (option -bg cmd)
launch_bg() {
    # Vérifications des arguments donnés, il doit y avoir 2 ou plus arguments.
    if [[ $# -ge 2 ]]; then 
        # # Création d'un tableau contenant tout les arguments du 2 jusqu'à la fin
        commande=("${@:2}")
        
        # Execution de la commande en arrière plan, redirigeant les potentielles erreurs retournées par la commande
        # "${commande[@]}" 2>/dev/null &

        {
            # echo "----- Début de la commande : ${commande[*]} -----"
            "${commande[@]}"
            # echo "----- Fin de la commande : ${commande[*]} -----"
        } 2>&1 | tee -a "$logfile" &
        

        # # Affichage d'un message de confirmation.
        echo "🚀 La commande '${commande[*]}' a été lancée en arrière-plan." | tee -a "$logfile"
    else
        # #Affichage d'un message d'erreur en cas de mauvaise utilisation
        echo "❌ Utilisation : -bg <commande> (ex : -bg sleep 10)" | tee -a "$logfile"
    fi
}

# Fonction pour Suspendre le processus pid (option -stop pid)
stop_process(){
    if [ -z "$1" ]; then # Vérification de l'existence de l'argument $1.
        # S'il n'existe pas, affichage d'un message d'erreur.
        echo "Sysmonitor.sh: -stop: l'option nécessite un PID." | tee -a "$logfile" 
        return 1 #Puis renvoi d'une erreur.
    elif ! [[ "$1" =~ ^[0-9] ]]; then # Vérification que le PID soit bien un nombre.
        # S'il n'est pas un nombre, affichage d'un message d'erreur.
        echo "Sysmonitor.sh: -stop: l'option attend un PID, pas un nom." | tee -a "$logfile"
        return 1 #Puis renvoi d'une erreur.
    # Vérification de l'existence du PID (qu'il corresponde bien à un processus en fonctionnement).
    elif ! kill -0 "$1" 2>/dev/null; then 
        # S'il ne correspond pas à un processus fonctionnel, affichage d'un message d'erreur.
        echo "Sysmonitor.sh: -stop: le PID $1 est introuvable." | tee -a "$logfile"
        return 1 #Puis renvoi d'une erreur.
    # Tentative d'exécuter la commande kill -STOP pour mettre en pause le processus associé au PID fourni.
    elif kill -STOP "$1" 2>/dev/null; then
        # Message de bonne réussite du programme.
        echo "Le processus possedant le PID $1 est maintenant suspendu." | tee -a "$logfile"
    else
        # S'il n'arrive pas à l'arrêter alors message d'erreur.
        echo "Sysmonitor.sh: -stop: Permissions insuffisantes pour suspendre le processus $1." | tee -a "$logfile"
        return 1 # Puis renvoi d'une erreur.
    fi
}

# Fonction pour Relancer le processus pid suspendu en arrière-plan (option -cont pid)
continue_process(){
    {
        # Vérification si on a mis un argument ou non
        process=$1
            if [[ -z $process ]]
            then    echo "Vous n'avez pas saisi le pid "
            return 1
            else    echo "PID saisi: $process"

            fi
        # Vérification de l'existance du PID parmi la liste des processus suspendus (numeros de pid)	
        
        jobs -s -p | grep -w ${process} #-w pour chercher le terme exact
        # retour=$?	
        # #récupération du code de retour de la commande grep (0 si pid trouvé dans la liste -existe- sinon 1 -n'existe pas)
        if [[ $? -eq 0 ]] 
        then 	#jobs -l | grep -w ${process}

            # match seulement le mot exact!! ici on veut récupérer le job associé au processus. 
            # Ne pas mettre des '' pour le grep -w avec variable
            
            # On filtre pour avoir seulement le numero de job
            n_job=$(jobs -l | grep -w ${process} | awk '{print $1}' | tr -d '[]+')

            # J'ai écrit de cette façon pour qu'on ait un message qui s'affriche si bg réussi. 
            
            # Je ne voulais mettre de if et utiliser $? pour être sûr que je vérifiais la bonne 
            # exécution de bg + pour ne pas alourdir le code
            bg %${n_job} && echo "Le processus ${process} a bien été relancé en arrière plan" || echo "Fail relancement du processus en bckgrund"
            return 0
        else	echo "Le processus saisi ne figure pas dans la liste des processus suspendus"
            return 1
        fi
    } 2>&1 | tee -a "$logfile"
}

# Fonction pour Terminer le processus pid (option -kill pid)
kill_process() {
	pid="$1"

	if [ -z "$pid" ]; then
		echo "❌ Erreur : aucun PID fourni." | tee -a "$logfile"
		return 1
	fi

	if kill -0 "$pid" 2>/dev/null; then
		kill "$pid"
		echo "🛑 Processus $pid terminé avec succès." | tee -a "$logfile"
	else
		echo "❌ Le processus $pid n'existe pas ou vous n'avez pas les droits nécessaires." | tee -a "$logfile"
	fi
}

# Fonction pour afficher l'aide du script avec des exemples (option -h ou --help)
print_help() {
	{
		# Titre de la section aide
		echo "=== AIDE : SysMonitor.sh ==="
		echo ""

		# Affiche la syntaxe de base pour exécuter le script
		echo "Usage : ./SysMonitor.sh [option] [arguments]"
		echo ""

		# Liste des options disponibles avec une brève description
		echo "Options disponibles :"
		echo "  (par défaut)        Affiche un résumé du système (CPU, RAM, uptime, disque)"
		echo "  -lp                 Liste tous les processus en cours via /proc"
		echo "  -s <pid>            Affiche les détails du processus avec le PID donné"
		echo "  -lcpu               Affiche les informations CPU extraites de /proc/cpuinfo"
		echo "  --save       	      Sauvegarde les informations système dans sysinfo.log"
		echo "  -bg <cmd>           Lance la commande <cmd> en arrière-plan"
		echo "  -stop <pid>         Suspend le processus ayant ce PID"
		echo "  -cont <pid>         Relance un processus suspendu"
		echo "  -kill <pid>         Termine le processus ayant ce PID"
		echo "  -h, --help          Affiche cette aide"
		echo ""

		# Section exemples pour illustrer chaque option
		echo "Exemples :"
		echo "  ./SysMonitor.sh                     # Affiche le résumé système"
		echo "  ./SysMonitor.sh -lp                 # Liste des processus actifs"
		echo "  ./SysMonitor.sh -s 1234             # Détails du processus 1234"
		echo "  ./SysMonitor.sh -lcpu               # Affiche les infos CPU"
		echo "  ./SysMonitor.sh --save              # Sauvegarde les infos système"
		echo "  ./SysMonitor.sh -bg 'firefox'       # Lance Firefox en arrière-plan"
		echo "  ./SysMonitor.sh -stop 1234          # Suspend le processus 1234"
		echo "  ./SysMonitor.sh -cont 1234          # Relance le processus 1234"
		echo "  ./SysMonitor.sh -kill 1234          # Termine le processus 1234"
		echo "  ./SysMonitor.sh -h                  # Affiche l'aide"
		echo "  ./SysMonitor.sh --help              # (équivalent de -h)"
		echo ""
	} | tee -a "$logfile"  # Affiche à l’écran et enregistre dans le fichier de log
	
	# Invite l’utilisateur à saisir une nouvelle ligne de commande (option valide)
	read -p "🔁 Choisissez une option (et un argument) : " input
	echo "" | tee -a "$logfile"  # Saut de ligne

	# Met à jour les arguments du script avec ceux saisis par l'utilisateur
	set -- $input  # Permet de gérer des options avec arguments comme -s 1234

	# Relance le switch principal avec les nouveaux arguments
	MAIN "$@"
}

# Fonction pour gérer une option invalide et redemander une entrée à l'utilisateur
invalid_option() {
	# Enregistre dans le fichier de log la commande entrée par l'utilisateur
	echo "./SysMonitor.sh $1" | tee -a "$logfile"

	# Affiche un message d'erreur indiquant que l'option est inconnue
	echo "❌ Erreur : option inconnue '$1'!" | tee -a "$logfile"

	# Invite l'utilisateur à saisir une option correcte
	echo "👉 Veuillez taper une option valide!" | tee -a "$logfile"
	echo "👉 Vous pouvez utiliser './SysMonitor.sh -h' pour voir les options disponibles." | tee -a "$logfile"

	# Invite l’utilisateur à saisir une nouvelle ligne de commande (option valide)
	read -p "🔁 Entrez une option valide : " input
	echo "" | tee -a "$logfile"  # Saut de ligne

	# Met à jour les arguments du script avec ceux saisis par l'utilisateur
	set -- $input  # Permet de gérer des options avec arguments comme -s 1234

	# Relance le switch principal avec les nouveaux arguments
	MAIN "$@"
}


# === Fonction principale pour gérer les options passées en argument ===
MAIN() {
	while true; do  # Boucle pour analyser les arguments passés au script
		case "$1" in
			# Option : -lp → Liste tous les processus actifs
			-lp)
				list_processes  # Appelle la fonction qui affiche la liste des processus
				break  # Sort de la boucle après exécution
				;;

			# Option : -s <pid> → Affiche les détails d’un processus spécifique
			-s)
                echo "./SysMonitor.sh -s $2" >> "$logfile"
				if [ -n "$2" ]; then
                    process_details "$2"  # Si un PID est fourni, affiche ses détails
				else
					echo "❌ Erreur : veuillez fournir un PID après -s" | tee -a "$logfile"  # Message d’erreur si aucun PID
				fi
				break
				;;

			# Option : -lcpu → Affiche les informations CPU
			-lcpu)
				echo "🧠 Affichage des informations CPU..."
				infos_cpu  # Appelle la fonction qui affiche les infos CPU
				break
				;;

			# Option : --save → Sauvegarde les informations système dans un fichier
			--save)
				echo "📁 Sauvegarde des informations système..."
				save_system_info  # Appelle la fonction de sauvegarde
				break
				;;

			# Option : -bg <cmd> → Exécute une commande en arrière-plan
			-bg)
                echo "./SysMonitor.sh -bg $2" >> "$logfile"
				if [ -n "$2" ]; then
					launch_bg "$@"  # Exécute la commande entière passée après -bg
				else
					echo "❌ Erreur : veuillez spécifier une commande après -bg"  | tee -a "$logfile"
				fi
				break
				;;

			# Option : -stop <pid> → Suspend un processus en envoyant le signal STOP
			-stop)
                echo "./SysMonitor.sh -stop $2" >> "$logfile"
				if [ -n "$2" ]; then
                    stop_process "$2"  # Suspend le processus avec le PID donné
					# stop_process $2
				else
					echo "❌ Veuillez fournir un PID après -stop" | tee -a "$logfile"
				fi
				break
				;;

			# Option : -cont <pid> → Relance un processus suspendu (signal CONT)
			-cont)
                echo "./SysMonitor.sh -cont $2" >> "$logfile"
				if [ -n "$2" ]; then
                    continue_process "$2"  # Relance le processus
				else
					echo "❌ Veuillez fournir un PID après -cont" | tee -a "$logfile"
				fi
				break
				;;

			# Option : -kill <pid> → Termine un processus en envoyant le signal KILL
			-kill)
                echo "./SysMonitor.sh -kill $2" >> "$logfile"
				if [ -n "$2" ]; then
					kill_process "$2"  # Tue le processus spécifié
				else
					echo "❌ Veuillez fournir un PID après -kill" | tee -a "$logfile"
				fi
				break
				;;

			# Option : -h ou --help → Affiche le guide d'utilisation
			-h|--help)
				echo "./SysMonitor.sh $1" >> "$logfile"  # Log l'utilisation de l’aide
				print_help  # Affiche le message d’aide
				break
				;;

			# Aucune option passée → Affiche un résumé système (ex. : infos CPU par défaut)
			"")
				cpu_info  # Affiche les informations système de base
				break
				;;

			# Option non reconnue → Affiche une erreur
			*)
				invalid_option "$1"  # Appelle la fonction de gestion d’erreurs
				return  # Termine la fonction proprement
				;;
		esac
	done
}

# Lancement de la fonction principale
MAIN "$@"