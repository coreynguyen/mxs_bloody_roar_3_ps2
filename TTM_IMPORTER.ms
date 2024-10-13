/* ----------------------------------------------------------
	C H A N G E    L O G
	Mar-14-2015
	

*/ ----------------------------------------------------------

clearlistener()
if classof substituteString == UndefinedClass do (
	fn substituteString inputString findthis replacewiththis ignoreCase:true = (
		local str = "", idx = #(), o = 0
		for i = 1 to inputString.count do (
			str = substring inputString i -1
			if str.count >= findthis.count do (
				if matchpattern str pattern:(findthis + "*") ignoreCase:ignoreCase do (
					append idx i
					)
				)
			)
		str = inputString
		o = replacewiththis.count - findthis.count
		for i = 1 to idx.count do (
			str = replace str (idx[i] + (o * (i - 1))) findthis.count replacewiththis
			)
		str
		)
	)
try(DestroyDialog bloodyroar3_imp)catch(bloodyroar3_imp)
rollout bloodyroar3_imp "Bloody Roar 3" (

	button btn1 "Import" width:120 height:30
	checkbox chk1 "Clear Scene" checked:true
	checkbox chk2 "Print Debug Info" checked:false
	spinner spn1 "Scale" range:[-999999999.0, 999999999.0, 3.93700787] type:#float scale:0.01 align:#left

	group "Tools" (
		button btn2 "Dump IMAGE00" width:120 height:30
		)
	
	label lbl1 ""
	label lbl2 "Written By mariokart64n"
	
	local f
	local filen=""
	local mscale=3.93700787
	fn hexFormat num datatype = (
		local len=0,str="",a=0,s="",i=0
		len = case datatype of (#byte:2; #short:4; #long:8; default:8;)
		str = bit.IntAsHex(num as integer) as string
		for i = 1 to str.count do (
			a = bit.CharAsInt str[i]
			if a > 0x40 do (str[i] = bit.IntAsChar(a - 0x20)) 
			)
		if str.count <= len then (
			for i = 1 to (len - str.count) do (str = "0" + str)
			)
		else (str = substring str 1 len)
		str
		)
	fn createFaces count = (
		local faceArray = #()
		local i=0, fa=1, fb=2, fc=3, fd=0
		if count>3 do (
			faceArray[(count-2)] = [1,1,1]
			faceArray[1] = [1,2,3]
			for i = 1 to (count-3) do (
				fd=fa; fa=fc; fc=fd
				fa+=1; fb+=1; fc+=1
				faceArray[(i + 1)] = [fa,fb,fc]
				)
			)
		faceArray
		)
	fn createFaces2 count = (
		local i=0,faceArray = #()
		faceArray[(count/3)] = [1,1,1]
		for i = 1 to (count/3) do (
			if mod i 2 == 0 then (
				faceArray[i] = ([1,2,3]+((i*3)-3))
				)
			else (
				faceArray[i] = ([1,3,2]+((i*3)-3))
				)
			)
		faceArray
		)
	fn buildObj Vert_array UV_array Face_array rangeCheck:true = (
		local msh,j=0
		if rangeCheck do (
			local num_verts = Vert_array.count
			for i = 1 to num_verts do (
				for v = 1 to 3 do (
					if Vert_array[i][v] > 999999.0 or Vert_array[i][v] < -999999.0 do (
						Vert_array[i][v] = 0.0
						)
					)
				)
			)
		msh = mesh vertices:Vert_array tverts:UV_array faces:Face_array-- materialIDs:g.matid 
		msh.numTVerts = UV_array.count
	-- 	msh.displayByLayer = false
	-- 	msh.backfacecull = on
		buildTVFaces msh
		for j = 1 to UV_array.count do setTVert msh j UV_array[j]
		for j = 1 to Face_array.count do setTVFace msh j Face_array[j]
		msh.wirecolor = random (color 0 0 0) (color 255 255 255)
		msh
		)
	fn checkFor_0x11_indextable = (
		local isThere = true, limit=500
		b1 = readshort f
		b2 = readshort f
		b3 = readshort f
		b4 = readshort f
	-- 	format "% % % %\n" b1 b2 b3 b4
		if b1>limit \
		or b2>limit \
		or b3>limit \
		or b4>limit do isThere=false
		fseek f -0x08 #seek_cur
		isThere
		)
	fn readChunk id count size offset verbose:false = (
		local i=0,x=0,v=0,a=[0,0,0,0],b=[0,0,0,0],d,pos=0,cur=0
		local count1=0,count2=0,block_offset=0,buffer_offset=0
		local unk01=0,unk02=0,unk03=0
		local unk04=0,unk05=0,unk06=0
		local u01=0,u02=0,u03=0,u04=0,u05=0,u06=0
		local u07=0,u08=0,u09=0,u10=0,u11=0,u12=0
		local vertArray = #()
		local uvwArray = #()
		local faceArray = #()
		if verbose do (
			format "Block %:\n\tAddress:\t0x%\n\tCount:\t%\n\tSize:\t0x%\n\n" \
				id (bit.intAsHex(offset as integer)) count (bit.intAsHex(size as integer))
			)
		case id of (
			0x01: ( -- Object Definitions
				fseek f 0x10 #seek_set
				buffer_offset = readlong f #seek_set
				for i = 1 to count do ( -- objects?
					fseek f (offset + ( (i-1) * 0x80 ) ) #seek_set
					count1 = readshort f #unsigned -- ? 1
					count2 = readshort f #unsigned -- ? 2
					block_offset = readlong f #unsigned -- offset
					readlong f #unsigned -- padding?
					
					[readfloat f,readfloat f,readfloat f,readfloat f] -- 4x4 matrix?
					[readfloat f,readfloat f,readfloat f,readfloat f]
					[readfloat f,readfloat f,readfloat f,readfloat f]
					[readfloat f,readfloat f,readfloat f,readfloat f]
					
					readlong f #unsigned -- wtfs?
					readlong f #unsigned
					readlong f #unsigned
					readlong f #unsigned
					
					readlong f #unsigned -- repeated wtfs ?
					readlong f #unsigned
					readlong f #unsigned
					readlong f #unsigned
					
					readshort f #unsigned -- sizes or counts?
					readshort f #unsigned
					readshort f #unsigned
					readshort f #unsigned
					readshort f #unsigned
					readshort f #unsigned
					readshort f #unsigned
					readshort f #unsigned
					
					fseek f block_offset #seek_set
					for x = 1 to count2 do (
						pos = ftell f
						unk01 = readbyte f #unsigned
						unk02 = readshort f #unsigned
						unk03 = readbyte f #unsigned
						unk04 = readlong f #unsigned
						unk05 = readlong f #unsigned
						unk06 = readlong f #unsigned
						u01=u02=u03=u04=u05=u06=u07=u08=u09=u10=u11=u12=0
						if verbose do (
							format "CMD: 0x%\tFlag: %\tCount: %\t@\t0x%\n" \
								(bit.intAsHex(unk01 as integer)) unk03 unk02 (bit.intAsHex(pos as integer))
							)
						vertArray = #()
						case unk01 of (
							0x06: (
								for x = 1 to unk02 do (
									u01 = readlong f #unsigned
									u02 = readlong f #unsigned
									u03 = readlong f #unsigned
									
									u04 = readlong f #unsigned -- offset
									u05 = readlong f #unsigned -- unknown?
									
									u07 = readshort f #unsigned
									u08 = readshort f #unsigned
									)
								)
							0x11: (
								for x = 1 to unk02 do (
									u01 = readlong f #unsigned
									u02 = readlong f #unsigned
									u03 = readlong f #unsigned
									
									u04 = readlong f #unsigned -- size
									u05 = readlong f #unsigned -- offset
									u06 = readlong f #unsigned -- unknown?
									
									if (checkFor_0x11_indextable())==true do (
										u07 = readshort f #unsigned -- counts
										u08 = readshort f #unsigned
										u09 = readshort f #unsigned
										u10 = readshort f #unsigned
										)
									
									u11 = [readfloat f,readfloat f,readfloat f] -- min / max
									u12 = [readfloat f,readfloat f,readfloat f]
									if verbose do (
										format "%\t%\t%\t|\t%\t%\t%\t|\t[% % % %]\n" \
											(hexFormat u01 #long) \
											(hexFormat u02 #long) \
											(hexFormat u03 #long) \
											((u04 / 16) as integer + 1) \
											((u05 / 16) as integer + 1) \ --hexFormat u05 #long
											((u06 / 16) as integer + 1) \ --hexFormat u06 #long
											(hexFormat u07 #short) \
											(hexFormat u08 #short) \
											(hexFormat u09 #short) \
											(hexFormat u10 #short)
										)
									cur = ftell f
									fseek f (buffer_offset + u04+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u05+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u06+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f cur #seek_set
									)
								buildObj vertArray vertArray (createFaces2(vertArray.count))
								if verbose do (format "\n\n")
								)
							0x12: (
								for x = 1 to unk02 do (
									u01 = readlong f #unsigned
									
									u04 = readlong f #unsigned -- unknown?
									u05 = readlong f #unsigned -- offset
									u06 = readlong f #unsigned -- unknown?
									
									u07 = readshort f #unsigned -- counts
									u08 = readshort f #unsigned
									u09 = readshort f #unsigned
									u10 = readshort f #unsigned
									if verbose do (
										format "%\t%\t%\t|\t%\t%\t%\t|\t[% % % %]\n" \
											(hexFormat u01 #long) \
											(hexFormat 0 #long) \
											(hexFormat 0 #long) \
											((u04 / 16) as integer + 1) \
											((u05 / 16) as integer + 1) \ --hexFormat u05 #long
											((u06 / 16) as integer + 1) \ --hexFormat u06 #long
											(hexFormat u07 #short) \
											(hexFormat u08 #short) \
											(hexFormat u09 #short) \
											(hexFormat u10 #short)
										)
									cur = ftell f
									fseek f (buffer_offset + u04+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u05+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u06+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f cur #seek_set
									)
								buildObj vertArray vertArray (createFaces2(vertArray.count))
								)
							0x1A: (
								for x = 1 to unk02 do (
									u01 = readlong f #unsigned
									
									u04 = readlong f #unsigned -- size
									u05 = readlong f #unsigned -- offset
									u06 = readlong f #unsigned -- unknown?
									
									u07 = readshort f #unsigned -- counts
									u08 = readshort f #unsigned
									u09 = readshort f #unsigned
									u10 = readshort f #unsigned
									)
								)
							0x25: (
								for x = 1 to unk02 do (
									u01 = readlong f #unsigned
									
									u04 = readlong f #unsigned -- size
									u05 = readlong f #unsigned -- offset
									u06 = readlong f #unsigned -- unknown?
									
									u07 = readshort f #unsigned -- counts
									u08 = readshort f #unsigned
									u09 = readshort f #unsigned
									u10 = readshort f #unsigned
									
									u11 = [readfloat f,readfloat f,readfloat f]
									u12 = [readfloat f,readfloat f,readfloat f]
									if verbose do (
										format "%\t%\t%\t|\t%\t%\t%\t|\t[% % % %]\t[% % %]\n" \
											(hexFormat u01 #long) 0 0 \
											((u04 / 16) as integer + 1) \
											((u05 / 16) as integer + 1) \ --hexFormat u05 #long
											((u06 / 16) as integer + 1) \ --hexFormat u06 #long
											(hexFormat u07 #short) \
											(hexFormat u08 #short) \
											(hexFormat u09 #short) \
											(hexFormat u10 #short) \
											(u11[1] + u11[2]) \
											(u11[3] + u12[1]) \
											(u12[2] + u12[3])
										)
									cur = ftell f
									fseek f (buffer_offset + u04+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u05+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u06+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f cur #seek_set
									)
								buildObj vertArray vertArray (createFaces2(vertArray.count))
								)
							0x26: (
								for x = 1 to unk02 do (
									u01 = readlong f #unsigned
									
									u04 = readlong f #unsigned -- size
									u05 = readlong f #unsigned -- offset
									u06 = readlong f #unsigned -- unknown?
									
									u07 = readshort f #unsigned -- counts
									u08 = readshort f #unsigned
									u09 = readshort f #unsigned
									u10 = readshort f #unsigned
									if verbose do (
										format "%\t%\t%\t|\t%\t%\t%\t|\t[% % % %]\n" \
											(hexFormat u01 #long) 0 0 \
											((u04 / 16) as integer + 1) \
											((u05 / 16) as integer + 1) \ --hexFormat u05 #long
											((u06 / 16) as integer + 1) \ --hexFormat u06 #long
											(hexFormat u07 #short) \
											(hexFormat u08 #short) \
											(hexFormat u09 #short) \
											(hexFormat u10 #short)
										)
									cur = ftell f
									fseek f (buffer_offset + u04+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u05+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f (buffer_offset + u06+16) #seek_set
									append vertArray [readfloat f,readfloat f,readfloat f]
									fseek f cur #seek_set
									)
								buildObj vertArray vertArray (createFaces2(vertArray.count))
								)
							0x28: (
								for x = 1 to unk02 do (
									u01 = readlong f #unsigned
									u02 = readlong f #unsigned
									u03 = readlong f #unsigned
									u04 = readlong f #unsigned
									if verbose do (
										format "%\t%\t%\t%\n" \
											(hexFormat u01 #long) \
											(hexFormat u02 #long) \
											(hexFormat u03 #long) \
											(hexFormat u04 #long)
										)
									)
								if verbose do (format "\n\n")
								)
							default: (
								format "ERROR:\n\tNEW CMD [0x%] @\t0x%\n\n" \
									(bit.intAsHex(unk01 as integer)) (bit.intAsHex(pos as integer))
								EXIT
								)
							)
						)
					)
				)
			0x02: ( -- Vertex / Normal Buffer
				for i = 1 to count do (
					a = [readfloat f,readfloat f,readfloat f]
					readfloat f
					if (mod i 2) == 0 then (
	-- 					d = dummy()
	-- 					d.boxsize = [0.1,0.1,0.1]
	-- 					d.position = a
	-- 					append vertArray a
	-- 					append uvwArray a
						)
					else (

						)

					)
	-- 			buildObj vertArray uvwArray (createFaces(vertArray.count))
				)
			0x03: (
				for i = 1 to count do ( -- each entry is 144 bytes
					readlong f #unsigned -- ?? 0
					readlong f #unsigned -- index
					readlong f #unsigned
					readshort f #unsigned
					readshort f #unsigned
					
					[readfloat f,readfloat f,readfloat f,readfloat f] -- 4x4matrix
					[readfloat f,readfloat f,readfloat f,readfloat f]
					[readfloat f,readfloat f,readfloat f,readfloat f]
					[readfloat f,readfloat f,readfloat f,readfloat f]
					
					[readfloat f,readfloat f,readfloat f,readfloat f] --? position?
					
					readlong f #unsigned -- wtf?
					readlong f #unsigned
					readlong f #unsigned
					readlong f #unsigned
					
					readlong f #unsigned -- wtf repeated?
					readlong f #unsigned
					readlong f #unsigned
					readlong f #unsigned
					
					readlong f #unsigned -- all 0's
					readlong f #unsigned
					readlong f #unsigned
					readlong f #unsigned
					)
				)
			0x04: (
				-- always has same address as block 0x03?
				)
			0x05: (
				for i = 1 to count do (
					readshort f #unsigned -- index
					)
				)
			)
		)
	fn readfile fsize verbose:false = (
		local h=0
		local offset = 0, flag = 0, size = 0, count = 5
		
		readlong f #unsigned -- 0x20 ?? ID
		readlong f #unsigned -- 0x00 ?? Padding?
		
		count = 5
		for h = 1 to count do (
			fseek f (h *  8) #seek_set
			offset = readlong f #unsigned
			flag = readlong f #unsigned
			if h != count then (
				fseek f ((h+1) *  8) #seek_set
				size = (readlong f #unsigned) - offset
				)
			else (
				size=fsize-offset
				)
			fseek f offset #seek_set
			readChunk h flag size offset verbose:verbose
			)
		)
	fn read filen = (
		if filen!=undefined and doesFileExist filen == true then (
			try(fclose f)catch()
			f = fopen filen "rb"
			if chk1.checked do (delete objects)
			
			print filen
			readfile (getFileSize filen) verbose:chk2.checked
			
			
			format "Last Read @ 0x%\n" (bit.intAsHex((ftell f)as integer))
			fclose f
			)
		else (
			format "Aborted\n"
			)
		)
	struct tblEntry_t ( -- 12 bytes per
		/* uint32 */ name_addr  = 0,   -- Address in the TBL file pointing to the filename
		/* uint32 */ dat_addr   = 0,    -- Position in the DAT file
		/* uint32 */ dat_size   = 0,    -- Size in bytes from position in the DAT file
		fn read f = (
			name_addr   = readLong f #signed
			dat_addr    = readLong f #signed
			dat_size    = readLong f #signed
			)
		)
	struct tbl_t ( -- 24 bytes
		/* uint16 */ unk1               = 1,    -- Always 1
		/* uint16 */ num_file           = 0,    -- Number of files
		/* uint16 */ num_file_entries   = 0,    -- Number of file entries
		/* uint16 */ unk2               = 0,    -- Always 0
		/* uint32 */ file_table_addr    = 24,   -- Address of the file table
		/* uint32 */ file_names_size    = 0,    -- Size of the file names block
		/* uint32 */ file_names_addr    = 0,    -- Address of the file names block
		/* uint32 */ tbl_filesize       = 0,    -- Size of the TBL file
		file_table                      = #(),  -- Array to store tblEntry_t structs
		names_buffer                    = #(),  -- Buffer for file names

		fn read f &strAddrLookUp = (
			-- Reading the header
			unk1                = readShort f #signed
			num_file            = readShort f #signed
			num_file_entries    = readShort f #signed
			unk2                = readShort f #signed
			file_table_addr     = readLong f #signed
			file_names_size     = readLong f #signed
			file_names_addr     = readLong f #signed
			tbl_filesize        = readLong f #signed
			
			-- Read file table entries
			fseek f file_table_addr #seek_set
			file_table = #()
			for i = 1 to num_file_entries do (
				local entry = tblEntry_t()
				entry.read(f)
				append file_table entry
				)
			
			-- Read file names
			fseek f file_names_addr #seek_set
			names_buffer = #()
			for i = 1 to num_file_entries do (
				append strAddrLookUp ((ftell f) as integer)
				append names_buffer (readString f)
				)
			)
		)
	fn extractTblAndDat mainFileName verbose:false = (
		
		if mainFileName != undefined and mainFileName != "" do (
			
			-- Check the extension of the provided file
			local extension = getFilenameType mainFileName
			local tblFileName = ""
			local datFileName = ""
			local fpath = getFilenamePath mainFileName
			local fname = getFilenameFile mainFileName
			
			if MatchPattern extension pattern:"*.tbl" ignoreCase:true then (
				tblFileName = mainFileName
				datFileName = (fpath + fname + ".dat")
				)
			else if MatchPattern extension pattern:"*.dat" ignoreCase:true then (
				datFileName = mainFileName
				tblFileName = (fpath + fname + ".tbl")
				)
			else (
				format "Error: Invalid file extension provided. Please provide either a .tbl or .dat file.\n"
				datFileName = undefined
				tblFileName = undefined
				)
			if datFileName != undefined and tblFileName != undefined do (
				-- Open the .tbl and .dat files
				local tblFile = fopen tblFileName "rb"
				local datFile = fopen datFileName "rb"
				
				if (tblFile != undefined and datFile != undefined) then (
					-- Create and read the TBL structure
					local tbl = tbl_t()
					local strAddrLookUp = #()
					tbl.read tblFile &strAddrLookUp
					
					local outputFolder = fpath + fname
					makeDir outputFolder all:true
					
					-- Loop through each file entry in the TBL
					for i = 1 to tbl.num_file_entries do (
						local entry = tbl.file_table[i]
						local fileName = "file_" + ((i - 1) as string)
						
						local filename_index = findItem strAddrLookUp entry.name_addr
						
						if filename_index > 0 do (
							fileName = substituteString tbl.names_buffer[filename_index] "/" "\\"
							)
						if (fileName != "" and entry.dat_size > 0) then (
							
							-- Create output file path and write the file
							local outputFilePath = outputFolder + "\\" + fileName
							local outputDir = getFilenamePath outputFilePath
							makeDir outputDir all:true
							
							local outFile = fopen outputFilePath "wb"
							
							local longsToRead = (entry.dat_size / 4) as integer
							local remainingBytes = entry.dat_size - (longsToRead * 4)
							
							-- Read in chunks of 4 bytes as signed longs
							fseek datFile entry.dat_addr #seek_set
							for i = 1 to longsToRead do (
								writeLong outFile (readLong datFile #signed) #signed
								)
							
							-- Read any remaining bytes one by one
							for i = 1 to remainingBytes do (
								writeByte outFile (readByte datFile #signed) #signed
								)
							
							fclose outFile
							
							if verbose do (format "Extracted: %\n" outputFilePath)
							)
						)
					fclose tblFile
					fclose datFile
					messageBox "Extraction Completed!"
					)
				else (
					format "Could not open either .tbl or .dat files\n"
					)
				)
			)
		)
	on btn1 pressed do (read(GetOpenFileName caption:"Select TTM File" types: "TTM (*.ttm)|*.TTM|All files (*.*)|*.*|"))
	on btn2 pressed do (
		extractTblAndDat (
			GetOpenFileName types:"Table Files (*.tbl)|*.tbl|All files (*.*)|*.*|"
			) verbose:chk2.checked
		)
	
	)
CreateDialog bloodyroar3_imp
/*
bloodyroar3_imp.read(
	"M:\\_GAMES\\Bloody Roar 3 (USA)\\Bloody Roar 3 (USA)\\samples\\1256.TTM"
	"M:\\_GAMES\\Bloody Roar 3 (USA)\\Bloody Roar 3 (USA)\\samples\\1073.TTM"
	"M:\\_GAMES\\Bloody Roar 3 (USA)\\Bloody Roar 3 (USA)\\IMAGE00\\CHR\\ALI\\0000.TTM"
	-- "M:\\_GAMES\\Bloody Roar 3 (USA)\\Bloody Roar 3 (USA)\\IMAGE00\\STG\\009\\0100.TTM" -- HUGE HEX
	-- "M:\\_GAMES\\Bloody Roar 3 (USA)\\Bloody Roar 3 (USA)\\samples\\1754.TTM" -- SQUARE PLANE
	-- "M:\\_GAMES\\Bloody Roar 3 (USA)\\Bloody Roar 3 (USA)\\IMAGE00\\STG\\002\\0000.TTM" -- STAGE
	-- "M:\\_GAMES\\Bloody Roar 3 (USA)\\Bloody Roar 3 (USA)\\IMAGE00\\STG\\002\\0500.TTM" -- HEX PLANE
	GetOpenFileName caption:"Select TTM File" types: "TTM (*.ttm)|*.TTM|All files (*.*)|*.*|"
	)
*/