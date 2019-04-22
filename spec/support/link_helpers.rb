# frozen_string_literal: true

module LinkHelpers
  def repository_path(owner, reposytory)
    File.join(repositories_path(owner), reposytory)
  end

  def repositories_path(owner)
    File.join('/', owner, 'repositories')
  end
end
