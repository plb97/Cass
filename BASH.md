#  Cass

## Bash

### Lecture

* [bash](https://wiki.bash-hackers.org/syntax/quoting)
* [...](https://wiki.bash-hackers.org/syntax/pe)
* [...](https://wiki.bash-hackers.org/syntax/pattern)
* [...](http://lkdjiin.github.io/blog/2015/05/02/comment-convertir-un-nombre-decimal-en-binaire-en-bash/)
* [...](https://linuxconfig.org/how-to-use-arrays-in-bash-script)
*

### Vérifier les variables d'environnement

    set|grep '^[[:alpha:]][[:alnum:]].*='
    

### Répertoire de définition du PATH

    /etc/paths.d/

### Depuis le début

    MYSTRING="Be liberal in what you accept, and conservative in what you send"
    echo ${MYSTRING#* } # " liberal in what you accept, and conservative in what you send"
    echo ${MYSTRING##* } # "send"

### Depuis la fin

    MYSTRING="Be liberal in what you accept, and conservative in what you send"
    echo ${MYSTRING% *} # Be liberal in what you accept, and conservative in what you
    echo ${MYSTRING%% *} # Be
