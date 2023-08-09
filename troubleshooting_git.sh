#!/bin/bash

echo "Wybierz opcję naprawy:"
echo "1. Prosta synchronizacja z zdalnym repozytorium"
echo "2. Użyj rebase, aby zsynchronizować historię"
echo "3. Wymuś aktualizację zdalnego repozytorium (OSTRZEŻENIE: ryzykowne)"
read -p "Wybierz numer opcji (1/2/3): " choice

case $choice in
    1)
        git fetch
        if git pull origin master; then
            git push origin master
        else
            echo "Wystąpił problem podczas synchronizacji. Spróbuj innej opcji."
        fi
        ;;

    2)
        git fetch
        if git pull --rebase origin master; then
            git push origin master
        else
            echo "Wystąpił problem podczas synchronizacji przy użyciu rebase. Spróbuj innej opcji."
        fi
        ;;

    3)
        read -p "Czy jesteś pewien, że chcesz wymusić aktualizację zdalnego repozytorium? (tak/nie): " confirm
        if [ "$confirm" == "tak" ]; then
            git push origin master --force
        else
            echo "Operacja przerwana przez użytkownika."
        fi
        ;;

    *)
        echo "Nieznana opcja. Spróbuj ponownie."
        ;;
esac

