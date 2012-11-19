for i in application*; do mv $i `echo $i | sed 's/application/Database/g'`; done;
