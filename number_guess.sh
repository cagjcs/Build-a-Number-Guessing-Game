#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\n*-*-*number guess*-*-*\n"

# Inicializa el número de intentos y la respuesta del jugador
INTENTOS=0
RESPUESTA=0
# Genera un número aleatorio entre 1 y 1000
NUMERO=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read NAME
if [[ -z $NAME ]]
then
  exit 0
else
  if [[ ${#NAME} -gt 18 ]]
  then
    echo "It must not be longer than 18 characters."
    exit 0
  fi
fi

SELECT_BD=$($PSQL "SELECT name, games, best FROM players WHERE name = '$NAME'")
if [[ -z $SELECT_BD ]]
  then
  	echo -e "\nWelcome, $NAME! It looks like this is your first time here."
  else
    IFS="|" read -r NAMEBD GAMES BEST <<< $SELECT_BD
    echo -e "\nWelcome back, $NAMEBD! You have played $GAMES games, and your best game took $BEST guesses."
fi

# Pide al jugador que ingrese un número
echo "Guess the secret number between 1 and 1000:"
while [ $RESPUESTA != $NUMERO ]
do
    read RESPUESTA
    # Incrementa el número de intentos
    INTENTOS=$((INTENTOS+1))
    # Verifica si la respuesta del jugador es correcta, demasiado alta o demasiado baja y que sea un numero
	  if [[ ! $RESPUESTA =~ ^-?[0-9]+$ ]]
  	then
    	echo "That is not an integer, guess again:"
  	elif [[ $RESPUESTA > $NUMERO ]]
  	then
    	echo "It's lower than that, guess again:"
  	elif [[ $RESPUESTA < $NUMERO ]]
  	then
    	echo "It's higher than that, guess again:"
  	elif [[ $RESPUESTA == $NUMERO ]]
  	then
    	echo "You guessed it in $INTENTOS tries. The secret number was $NUMERO. Nice job!"
  	fi
done

# Guardar resultados en la BD
SELECT_BD=$($PSQL "SELECT games, best FROM players WHERE name = '$NAME'")
if [[ -z $SELECT_BD ]]
then
  NUEVO_RESULT=$($PSQL "INSERT INTO players(name, games, best) VALUES('$NAME', 1, $INTENTOS)")
else
	if [[ $BEST < $INTENTOS ]]
	then
  	UPDATE_RESULT=$($PSQL "UPDATE players SET games = games + 1 WHERE name='$NAME'")
	else
  	UPDATE_RESULT=$($PSQL "UPDATE players SET games = games + 1, best = $INTENTOS WHERE name = '$NAME'")
	fi
fi
