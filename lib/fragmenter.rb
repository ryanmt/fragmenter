require 'data'
class Fragmenter
	include Ms

	attr_accessor :list
	TableEntry = Struct.new(:ion, :seq, :mass, :charge)
	Default_fragments = {:b => true, :y => true}
	def initialize(opts= {})
		@opts = Default_fragments.merge(opts)
		@n_term_search_ion_types = []
		@c_term_search_ion_types = []
		opts = Default_fragments.merge(opts)
		opts.each do |key, v|
			if v
				case key 
					when :b
						@n_term_search_ion_types.push(:b, :b_star, :b_not)
					when :a
						@n_term_search_ion_types.push(:a, :a_star, :a_not)
					when :c
						@n_term_search_ion_types << :c
					when :x
						@c_term_search_ion_types << :x
					when :y
						@c_term_search_ion_types.push(:y, :y_star, :y_not)
					when :z
						@c_term_search_ion_types << :z
				end
			end
		end
	end #initialize
		
	def calculate_fragments(sequence)
		arr = sequence.upcase.split('')
		out = [[],[]]
		(0..arr.size-2).each do |i|
			out[0] << arr[0..i].join
			out[1] <<  arr[(i+1)..-1].join
		end
		out
	end
	def generate_fragment_masses(sequence) # Returns the TableEntry object which should be easy to use for table generation
		@sequence = sequence
		@max_charge = charge_at_pH(identify_potential_charges(sequence), 2).round
		### Calculate the base ion masses	
		n_terms, c_terms = calculate_fragments(sequence)
		n_terms.map! do |seq|
			mass = Ms::NTerm
			seq.chars.map(&:to_sym).each do |residue|
				mass += Ms::ResidueMasses[residue]
			end
			[seq, mass]
		end
		c_terms.map! do |seq|
			mass = Ms::CTerm
			seq.chars.map(&:to_sym).each do |residue|
				mass += Ms::ResidueMasses[residue]
			end
			[seq, mass]
		end
### Tablify and generate a comprehensive list of ions
		list = []
		send_to_list = lambda do |fragment_arr, iontypes_arr|
			fragment_arr.each do |n_terms|
				seq = n_terms.first
				mass = n_terms.last
				iontypes_arr.each do |iontype|
					(1..@max_charge).each do |charge|
						charge_legend = '+'*charge
						list << TableEntry.new("#{iontype}(#{seq.size})#{charge_legend}".to_sym, seq, charge_state(mass + IonTypeMassDelta[iontype], charge), charge)
					end # 1..max_charge
				end	# iontypes_arr
			end # fragment_arr
		end # lambda block
		send_to_list.call(n_terms, @n_term_search_ion_types)
		send_to_list.call(c_terms, @c_term_search_ion_types)		
		@list = list
	end	
	def to_mgf(seq = nil)
		if seq.nil?
			seq = @sequence
			list = @list
		else
			list = generate_fragment_masses(seq)
		end
		intensity = 1000 # An arbitrary intensity value
		output_arr = []
		output_arr << %Q{COM=Project: In-silico Fragmenter\nBEGIN IONS\nPEPMASS=#{precursor_mass(seq, @max_charge)}\nCHARGE=#{@max_charge}+\nTITLE=Label: Sequence is #{seq}}
		list.sort_by{|a| a.mass}.each do |table_entry|
			#	TableEntry = Struct.new(:ion, :seq, :mass, :charge)
			output_arr << "#{"%.5f" % table_entry.mass }\t#{intensity}"
		end
		output_arr << "END IONS"
		File.open("#{seq}.mgf", 'w') {|o| o.print output_arr.join("\n") }
		output_arr.join("\n")
	end
	def graph(list = nil)
		list ? list : list = @list
		require 'rserve/simpler'
		robj = Rserve::Simpler.new
		hash = {}
		hash["mass"] = list.map{|a| a.mass}
		hash["intensity"] = list.map{ 1000}
		robj.converse( masses: hash.to_dataframe) do 
			"attach(masses)"
		end
		#robj.converse( data: Rserve::DataFrame.from_structs(list))
		robj.converse do 
			%Q{png(file='/home/ryanmt/Dropbox/coding/bootcamp/fragmenter/#{@sequence}_spectra.png')
				plot(masses$mass, masses$intensity, type='h')
				dev.off()
		}
		end	
	end
		
end
 
######### Testing stuff

test = "HELL"
test2= "AALK"

f = Fragmenter.new
f.generate_fragment_masses(test2)
f.to_mgf

f.to_mgf(test2)
f.to_mgf("VFSNGADLSGVTEEAPLK")
f.list



