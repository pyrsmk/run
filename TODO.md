# TODO

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
