# config/initializers/webpacker_patch.rb
# revert of https://github.com/rails/webpacker/commit/3760588534c54527d21c684c2cb5ca30cafc0901
module WebpackerChdirPatch
  def watched_files_digest
    warn "Webpacker::Compiler.watched_paths has been deprecated. Set additional_paths in webpacker.yml instead." unless watched_paths.empty?

    files = Dir[*default_watched_paths, *watched_paths].reject { |f| File.directory?(f) }
    file_ids = files.sort.map { |f| "#{File.basename(f)}/#{Digest::SHA1.file(f).hexdigest}" }
    Digest::SHA1.hexdigest(file_ids.join("/"))
  end
end


Webpacker::Compiler.prepend WebpackerChdirPatch