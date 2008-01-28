require 'fileutils'

module Rush
	module Connection
		class Local
			def write_file(full_path, contents)
				::File.open(full_path, 'w') do |f|
					f.write contents
				end
				true
			end

			def file_contents(full_path)
				::File.read(full_path)
			end

			def destroy(full_path)
				raise "No." if full_path == '/'
				FileUtils.rm_rf(full_path)
				true
			end

			def create_dir(full_path)
				FileUtils.mkdir_p(full_path)
				true
			end

			class NameAlreadyExists < Exception; end
			class NameCannotContainSlash < Exception; end
			class NotADir < Exception; end

			def rename(path, name, new_name)
				raise NameCannotContainSlash if new_name.match(/\//)
				old_full_path = "#{path}/#{name}"
				new_full_path = "#{path}/#{new_name}"
				raise NameAlreadyExists if ::File.exists?(new_full_path)
				FileUtils.mv(old_full_path, new_full_path)
				true
			end

			def copy(src, dst)
				raise NotADir unless ::File.directory?(dst)
				raise NameAlreadyExists if ::File.exists?("#{dst}/#{::File.basename(dst)}")
				FileUtils.cp_r(src, dst)
				true
			end

			class UnknownAction < Exception; end

			def receive(params)
				case params[:action]
					when 'write_file'     then write_file(params[:full_path], params[:payload])
					when 'file_contents'  then file_contents(params[:full_path])
					when 'destroy'        then destroy(params[:full_path])
					when 'create_dir'     then create_dir(params[:full_path])
					when 'rename'         then rename(params[:path], params[:name], params[:new_name])
					when 'copy'           then copy(params[:src], params[:dst])
				else
					raise UnknownAction
				end
			end
		end
	end
end
