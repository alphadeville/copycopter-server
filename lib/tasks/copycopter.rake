namespace :copycopter do
  task :regenerate_project_caches => :environment do
    Project.regenerate_caches
  end

  desc 'Add a project to Copycopter'
  task :project => :environment do
    project = Project.new(:name => ENV['NAME'], :password => ENV['PASSWORD'], :username => ENV['USERNAME'])

    if project.save
      puts "Project #{project.name} created!"
    else
      puts "There were errors creating the project: #{project.errors.full_messages}"
    end
  end

  desc 'Remove the project from Copycopter'
  task :remove_project => :environment do
    project = Project.where(:name => ENV['NAME']).first

    if project.destroy
      puts "Project #{project.name} removed!"
    else
      puts "There were errors removing the project: #{project.errors.full_messages}"
    end
  end

  desc 'Change the password of a Copycopter Project account'
  task :change_project_password => :environment do
    project = Project.where(:name => ENV['NAME']).first
    old_password = project.password

    project.password = ENV['NEW']

    if ENV['OLD'] == old_password && project.save
      puts "Project #{project.name} password has been updated!"
    else
      puts "You must know the old password to the project to update to the new password."
    end
  end

  desc 'Destroy localizations with locales not permitted'
  task :destroy_localizations_not_permited => :environment do
    Localization.delete( Localization.where("locale_id NOT IN (?)", Locale.locales_permitted) )
    Locale.delete( Locale.where("id NOT IN (?)", Locale.locales_permitted) )
    puts "All not permitted localizations deleted successfully!"
  end

  desc 'Purge old blurbs versions on all projects'
  task :destroy_old_versions => :environment do
    lates_versions = []
    Localization.all.each do |localization|
      if latest_version = localization.latest_version
        lates_versions << latest_version.id
      end
    end
    Version.delete( Version.where("localization_id NOT IN (SELECT id FROM localizations)") )
    Version.delete( Version.where("id NOT IN (?)", lates_versions) )
    puts "Old versions deleted successfully!"
  end

end
