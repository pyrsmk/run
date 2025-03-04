# TODO

- rajouter le support de "flags"
  - dans WizvilleMobile, la tâche `dev` gère pas mal de choses et on a donc `dev_production_mode`, `dev_tunnel` et `dev_clean` qui ont été créés pour gérer des options supplémentaires à déclencher sur `dev`
  - c'est pas super pratique, il nous faudrait quelque chose du genre : `run dev +tunnel`
  - cette commande appèlerait donc `dev` avec l'option `tunnel` à true
  - un autre préfixe peut être utilisé, à voir avec l'équipe qui serait préférable
  - dans tous les cas, faire attention à supporter Ruby 2.4 et 3.3
- complétion automatique dans le terminal
- réintégrer/refactoriser require_remote
  - ne pas utiliser un provider externe, permettre juste de loader une URL externe et de mettre en cache
  - intégrer l'extension docker directement dans run et utilisation via `require "run/docker"`
  - écrire les tests
  - ancienne implem :
  ```rb
    # @param uri [String]
    # @return [void]
    def require_remote(uri)
      cache_path = "/tmp/run_cache_#{Digest::MD5.hexdigest(uri)}"
      if !File.exists? cache_path
        File.write(cache_path, URI.parse(uri).open.read)
      end
      eval File.read(cache_path)
    rescue => error
      puts
      puts "Unable to load #{uri}:".red
      puts "#{error.class}: #{error.message}".red
      exit 8
    end
  ```
