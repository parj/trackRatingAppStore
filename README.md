# trackRatingAppStore

Used to extract rating from app store given an appstore url. This is just a simple shell script to scrape a website and dump to a local csv file. To use

    ./main.sh  --url https://apps.apple.com/gb/app/hsbc-kinetic/id1457310350 --type Finance


Usage is:

    This is used for grabbing app store rating

    Available options:
        -u / --url              The app store URL to parse - example https://apps.apple.com/gb/app/hsbc-kinetic/id1457310350
        -t / --type             The category of the app in the appstore - example Finance
        --tracking-file         The name of the csv file to write to
        -h / --help             This message