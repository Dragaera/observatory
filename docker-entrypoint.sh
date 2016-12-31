#!/bin/bash

case "$1" in
    application)
        echo "Starting application server..."
        exec unicorn -c unicorn.conf.rb
        ;;
    rake)
        echo "Calling Rake task $2"
        exec rake $2
        ;;
    migrate)
        echo "Applying database migrations"
        exec rake sq:migrate
        ;;  
    shell)
        echo "Opening Padrino shell"
        exec padrino c
        ;;

    *)
        echo "Don't know what to do with $1"
        echo "Valid commands: application, rake, shell"
        exit 1
esac
