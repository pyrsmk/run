- retour à la ligne automatique avec la bonne indentation dans l'écran d'aide pour les lignes jugées trop longues
  ```rb
  require "io/console"
  IO.winsize[1]
  ```
- support des tableaux de nom en paramètre de tâches
  ```rb
  # task [:console, :c] do
  #   call "crystal i"
  # end
  ```
- complétion automatique dans le terminal
- natural sort pour le listing des tâches dans l'aide
- support de -v et --version et version
- support de -h et --help
- help et version sont des tâches réservées
- refactoriser require_remote
  - ne pas utiliser un provider externe, permettre juste de loader une URL externe et de mettre en cache
  - intégrer l'extension docker directement dans run et utilisation via `require "run/docker"`
  - écrire les tests
