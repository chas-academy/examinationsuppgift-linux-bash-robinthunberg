#!/bin/bash
# skapar användare med mappar och en välkomstfil
# kör såhär: sudo ./create_users.sh Anna Bjorn Charlie

# måste vara root för att köra detta
if [ "$EUID" -ne 0 ]
then
    echo "du måste vara root, kör med sudo"
    exit 1
fi

# kollar att man skrivit in minst ett namn
if [ "$#" -eq 0 ]
then
    echo "skriv in namn såhär: ./create_users.sh Anna Bjorn"
    exit 1
fi

# första loopen - skapar alla användare och mappar
for USERNAME in "$@"
do
    # hoppar över om användaren redan finns
    if id "$USERNAME" &>/dev/null
    then
        echo "$USERNAME finns redan, hoppar över"
    else
        # skapar användaren
        useradd -m -s /bin/bash "$USERNAME"

        # skapar mapparna
        mkdir /home/$USERNAME/Documents
        mkdir /home/$USERNAME/Downloads
        mkdir /home/$USERNAME/Work

        # sätter rättigheter så bara ägaren kommer åt mapparna
        chmod 700 /home/$USERNAME/Documents
        chmod 700 /home/$USERNAME/Downloads
        chmod 700 /home/$USERNAME/Work

        # sätter rätt ägare på allt
        chown -R $USERNAME:$USERNAME /home/$USERNAME

        echo "$USERNAME är nu skapad!"
    fi
done

# andra loopen - nu när alla användare finns skapar vi välkomstfilerna
for USERNAME in "$@"
do
    # skapar välkomstfilen med användarens namn
    echo "Välkommen $USERNAME" > /home/$USERNAME/welcome.txt
    echo "" >> /home/$USERNAME/welcome.txt
    echo "Andra användare på systemet:" >> /home/$USERNAME/welcome.txt

    # läser /etc/passwd och listar andra användare
    while IFS=: read -r NAME PASS UID_NUM REST
    do
        if [ "$UID_NUM" -ge 1000 ] && [ "$NAME" != "$USERNAME" ] && [ "$NAME" != "nobody" ]
        then
            echo "- $NAME" >> /home/$USERNAME/welcome.txt
        fi
    done < /etc/passwd

    # sätter rätt ägare på välkomstfilen
    chown $USERNAME:$USERNAME /home/$USERNAME/welcome.txt
done

echo "klart!"
