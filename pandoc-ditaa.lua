
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Main TOC:
--   main sec-1: Script scope variable declerations
--   main sec-2: Check if java & ditaa paths exist
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Main Sec-1: Script scope variable declerations
--   main sec-1 sub-1: Script scope variable declerations
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

--******************************************************************************
-- Main Sec-1 Sub-1: Script scope variable declerations
--******************************************************************************

local intImageCnt = 0;      -- Number of images made (so naming is uniqe)
local javaPathStr = "java"; -- path to java binaray (default; in system path)
local callDitaaStr = "";    -- Path od ditaa

-- Output:
--   Modifies: callDitaaStr to have javaPathStr -jar ditaaxxx.jar
function findDitaaPath()
  -- Sets up call command for ditaa

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? TOC: 
  --   fun-? sec-1: Variable declerations
  --   fun-? sec-2: Check if programs exist
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-1: Variable declerations
  --   fun-? sec-1 sub-1: Declare file paths & names for ditaa program
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  --****************************************************************************
  -- Fun-? Sec-1 Sub-1: Declare file paths & names for ditaa program
  --****************************************************************************

  local pathsStr = {
      callDitaaStr,                       -- User provided?
      "/usr/local/bin/",                  -- Likely unix location
      "C:\\\\program files\\",            -- likey windows location?
      ""                                  -- In directory
    };

  local ditaaStr = {
      "ditaa-0.11.0.jar",                 -- version 11 name of ditaa (git hub)
      "ditaa.jar",                        -- Maybe user removed version?
      "ditaa_0.9.jar"                     -- version 9 of ditaa (source forge)
    };

  local ditaaTestFile = nil;

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-2: Check if programs exist
  --   fun-? sec-2 sub-1: Check if path to java was found
  --   fun-? sec-2 sub-2: Check if path to ditaa file exists
  --   fun-? sec-2 sub-3: There is not path to ditaa, retun nil
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  --****************************************************************************
  -- Fun-? Sec-2 Sub-1: Check if path to java was found
  --****************************************************************************

  if javaPathStr == nil then
    return;
  end

  --****************************************************************************
  -- Fun-? Sec-2 Sub-2: Check if path to ditaa file exists
  --****************************************************************************

  for strKey, strFile in pairs(ditaaStr) do
    for strTmp, strPath in pairs(pathsStr) do
       ditaaTestFile =
         io.open(
           strPath ..     -- path to ditaa checking
           strFile,       -- name of ditaa program checking
           "r"            -- open read only, just want to see if present
       ); -- See if can open the ditaa jar file

       if ditaaTestFile then
         io.close(ditaaTestFile);    -- close opened file (no longer need)
         return strPath .. strFile;  -- return the path to ditaa
       end
    end -- for all possible ditaa names, see if exists
  end -- for all possible file paths to ditaa

  --****************************************************************************
  -- Fun-? Sec-2 Sub-3: There is not path to ditaa, retun nil
  --****************************************************************************

  return nil;  -- Could not find path to ditaa
end -- findDitaaPath function

--##############################################################################
-- Output: 
--  Modifies: javaPathStr to point to the java binary (if not found sets to nil)
--##############################################################################
function findJavaPath() -- use: finds a valid path to java (if exists)

  -- Fun-? Sec-1 Sub-1: Check if default java path is valid
  local pathToJavaStr = javaPathStr;

  print("Testing if can call java");

  if os.execute(pathToJavaStr .. " -version") == 0 then
    return pathToJavaStr;
  end -- If default java path worked (printed version number)

  if os.execute("java -version") == 0 then
    pathToJavaStr = "java";
    return pathToJavaStr;
  end -- If default java path worked (printed version number)

  pathToJavaStr = os.getenv("JAVA_HOME"); -- if OS has enviromental var to java

  if pathToJavaStr and os.execute(pathToJavaStr .. " -version") == 0 then
    pathToJavaStr = pathToJavaStr .. "/bin";
    return pathToJavaStr;
  end

  pathToJavaStr = os.getenv("JRE_HOME"); -- if OS has enviromental var to java

  if pathToJavaStr and os.execute(pathToJavaStr .. " -version") == 0 then
    pathToJavaStr = pathToJavaStr .. "/bin";
    return pathToJavaStr;
  end

  if pcall(               -- returns false if pandoc.pipe errors out
       pandoc.pipe,       -- Function to call with pcall (errors out if no path)
       "javaPathHelper",  -- Program to call with pandoc.pipe
       {"-c", "java"},    -- table of args to input to javaPathHelper
       ""                 -- stdin to input to javaPathHelper
     ) -- see if javaPathHelper can give us the path
  then
    pathToJavaStr =
      pandoc.pipe(         -- returns output from javaPathHelper (path to java)
        "javaPathHelper",  -- Program to call with pandoc.pipe
        {"-c", "java"},    -- table of args to input to javaPathHelper
        ""                 -- stdin to input to javaPathHelper
    );

    return pathToJavaStr;
  end -- If javaPathHelper found the java binaray (printed version number)

  pathToJavaStr = "/usr/bin/java";  -- May work, but not likely

  if os.execute(pathToJavaStr .. " -version") == 0 then
    return pathToJavaStr;
  end -- If java has a link in /usr/bin (printed version number)

  pathToJavaStr = nil;               -- Can not figure out how to call java
end -- end findJavaPath function

--##############################################################################
-- Output:
--   Modifies: default java (pathToJavaStr) & ditaa path (callDitaaStr) to user
--##############################################################################
local function Meta(
  metaObj
) -- Get parameters user provided from meta data

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? TOC: Find path to ditaa & java
  --   fun-? sec-1: Get user supplied java & ditaa path from meta data
  --   fun-? sec-2: Check if user provided correct path, if not check defaults
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-1: Get user supplied java & ditaa path from meta data
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  for strKey, strValue in pairs(metaObj) do
    if strKey == "ditaa-path" then
      callDitaaStr = strValue[1].text;
    end

    if strKey == "java-path" then
      javaPathStr = strValue[1].text;
    end
  end

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-2: Check if user provided correct path, if not check defaults
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  javaPathStr = findJavaPath();             -- See if can find an java exectuable
  callDitaaStr = findDitaaPath();           -- See if have a valid path to ditaa
  
  if callDitaaStr then
    callDitaaStr = 
      string.gsub(
        javaPathStr ..                      -- path to java
          " -jar " ..                       -- Run jar file with java (ditaa.jar)
          callDitaaStr,                     -- path to ditaa*.jar
        "\n",                               -- remove new lines
        ""                                  -- replace new line char with nothing
    ); -- Build path to ditaa & make sure one line
  end -- If have a valid path to ditaa, else just leave as nil
end

--##############################################################################
-- Output:
--  File: flow digram made by ditaa (name fileNameStr)
--##############################################################################
local function callDitaa(
  textToConvStr, -- text with ditaa block to convert to image
  fileNameStr,   -- file name to call the output png from ditaa
  settingsStr    -- settings to send to ditaa
) -- Calls ditaa to make the image to send into pandoc
  local tmpFileStr = '901983745762345768-ditaa.ditaa'; -- random file name
  local srcFileStr =
          io.open(
            tmpFileStr,  -- file name to write string to
            'w'          -- write ditaa block to a file
  ); -- file to hold ditaa block

  srcFileStr:write(textToConvStr);              -- write ditaa block to file
  srcFileStr:close();                           -- close file
  os.execute(
    callDitaaStr ..          -- path/to/java -jar ditaaxxxx (calls ditaa)
    ' ' ..                   -- space to seperate ditaa from arguments
    tmpFileStr ..            -- file for ditaa to convert to image
    ' ' ..                   -- space to separate input from output
    fileNameStr ..           -- file name of file to make
    " -o " ..                -- -o to ovewrite old files
    settingsStr              -- Settings to send into ditaa
  ); -- Execute ditaa from os comand

  os.remove(tmpFileStr)      -- Remove the file I fed into ditaa
end -- end of callDitaa function

--##############################################################################
-- Output:
--   image: To add to markdown document
--##############################################################################
function CodeBlock(
  codeBlockObj      -- CodeBlock provided by pandoc (fires from pandoc)
)  -- CodeBlock function from Pandoc. Fires for each codeblock in a markdown
   -- document & checks if is a ditaa block. If a ditta block it then converts
   -- it to an image & inputs into document as a figure

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-1: Variable declerations
  --   fun-? sec-1 sub-1: Variable declerations
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  --****************************************************************************
  -- Fun-? Sec-1 Sub-1: Variable declerations
  --****************************************************************************


  local nextNewLineInt = 0;     -- Holds location of first or last new line
  local ditaaSetStartInt = 0;   -- Holds location of user input
  local ditaaParmStr = "";      -- Holds ditaa paramters the user supplied 
  local ditaaFileStr = "ditaa"; -- prefix to name ditaa file
  local fileExtStr = "png";     -- file extension to add to ditaa output file

  local descStartInt = 0;       -- Starting point of user description
  local descEndInt = 0;         -- Ending point of user description
  local descStr = "";           -- Description of flow chart

  local crossRefTagStartInt = 0;   -- Starting index for image settings
  local crossRefTagEndInt = 0;     -- Ending index for image settings
  local crossRefTagStr = "";       -- Settings to apply to image

  local intPos = 0;             -- Temporary counter

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-2: Find end extract user settings for ditaa
  --   fun-? sec-2 sub-1: Check if code block is a ditaa block
  --   fun-? sec-2 sub-2: Find start of settings for ditaa (& first new line)
  --   fun-? sec-2 sub-3: Confirm & extract user settings for ditaa
  --   fun-? sec-2 sub-4: Check if saving svg or png
  --   fun-? sec-2 sub-5: Remove blank lines / only white space lines at start
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  --****************************************************************************
  -- Fun-? Sec-2 Sub-1: Check if code block is a ditaa block
  --****************************************************************************

  if not codeBlockObj.attr.classes[1] then
    return codeBlockObj;  -- If is nill (no attribute)
  end

  if not codeBlockObj.attr.classes[1] == "ditaa" then
    return codeBlockObj;  -- If is not a ditta block
  end

  --****************************************************************************
  -- Fun-? Sec-2 Sub-2: Find start of settings for ditaa (& first new line)
  --****************************************************************************

  nextNewLineInt =
    re.find(
      codeBlockObj.text, -- string to search for newline in
      "%nl"              -- re.find code for newline
  ); -- Find first new line (so can see if [.*] at start is settings for ditaa)

  ditaaSetStartInt =
    string.find(           -- finds regular expression in string
      codeBlockObj.text,   -- string to search for pattern in
      "%["                 -- Find the first [ in my string
  ); -- find user input (if user input something)

  --****************************************************************************
  -- Fun-? Sec-2 Sub-3: Confirm & extract user settings for ditaa
  --****************************************************************************

  if ditaaSetStartInt and               -- is a ditaa settings block
     ditaaSetStartInt < nextNewLineInt -- ditaa setting block is before newline
  then
  -- If user may have provided settings for ditaa (first [.*])

    intPos = 
      string.find(
        codeBlockObj.text, -- string to search for end of ditaa options block in
        "%]"               -- end of ditaa block (is ])
    ); -- Search for end of ditaa input block

    if intPos and intPos < nextNewLineInt then
    -- if the end of ditaa settings block is before first new line
      ditaaParmStr = 
        string.sub(
          codeBlockObj.text,     -- Text with user parameters
          ditaaSetStartInt + 1,  -- Starting index of user parameters (at [)
          intPos - 1    -- Start of first new line
      ); -- Get the user provided parameters for ditaa

      codeBlockObj.text = -- remove the user settings from the flow chart
        string.sub(
          codeBlockObj.text,
          nextNewLineInt + 1,  -- Start at the end of the first new line
          -1                   -- Till the end of the string
      );

      --************************************************************************
      -- Fun-? Sec-2 Sub-5: Remove blank lines / only white space lines at start
      --************************************************************************

      codeBlockObj.text = -- remove any empty lines at the start
        string.gsub(
          codeBlockObj.text,   -- ditaa block to search for white space in
          "^[ \t\n\r]*[\n\r]", -- ^ is start of string, [ \t] = space or tab
          "",                  -- Replace the white space with "'
          1                    -- Only do subsitution for one time
      ); -- remove white space at start of file (if only blank line or spaces)
    end -- if the end of ditaa settings block is before first new line

    -- Else the block was not a set of settings for ditaa

    --**************************************************************************
    -- Fun-? Sec-2 Sub-4: Check if saving svg or png
    --**************************************************************************

    if string.find( ditaaParmStr, "--svg") then
      fileExtStr = "svg";
    end
  end -- If user may have provided settings for ditaa (first [.*])

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-3: Find the image settings and description from ditaa block
  --   fun-? sec-3 sub-1: Find image description at end of ditaa block
  --   fun-? sec-3 sub-2: Find if user provided a pandoc crossref tag
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  --**************************************************************************
  -- Fun-? Sec-3 Sub-1: Find image description at end of ditaa block
  --**************************************************************************

  while intPos do
  -- while there is a [.*] block to check (last one has image description)
     intPos = string.find(codeBlockObj.text, "%[.*%]", intPos) 

     if intPos then
       descStartInt = intPos;       -- Starting point of user description
       intPos = intPos + 1;
     end
  end -- while there is a [.*] block to check (last one has image description)
  
  -- Find the closing brace
  descEndInt = string.find(codeBlockObj.text, "%]", descStartInt) 

  --**************************************************************************
  -- Fun-? Sec-3 Sub-2: Find if user provided tag block (maybe cross ref tag)
  --**************************************************************************

  if descEndInt then   -- if have an end to the description (not nil)
  -- If there was a description block, check to see if is a settings block
    crossRefTagStartInt = string.find(codeBlockObj.text, "{", descEndInt);

    if crossRefTagStartInt then
    -- If the user may have provided image settings
      crossRefTagEndInt = 
        string.find(         -- Find function for strings
          codeBlockObj.text, -- String to search for image settings block in
          "}",               -- image settings block ends with }
          crossRefTagStartInt   -- Starting point of image settings block
      ); -- Find the end of the image settings block

      if crossRefTagEndInt then
      -- If there was a settings block (had an end), check if newline after
        nextNewLineInt =
          re.find(
            codeBlockObj.text, -- Strig to search for new line after block in
            "%nl",             -- is newline
            crossRefTagEndInt     -- ending point of image settings block
        ); -- See if new line is at end
      -- If there was a settings block (had an end), check if newline after

      else
        nextNewLineInt = nil; -- image block not closed (no })
          -- Means user error or user did not intend last [.*] to be description
          -- Assuming user new what was doing
      end -- check if have image settings end
    -- If the user may have provided image settings

    else
    -- Else no user settings
      nextNewLineInt =
        re.find(
          codeBlockObj.text, -- String to see if newline is after description
          "%nl",             -- means newline
          descEndInt         -- end of the description block
      ); -- See if there is a newline after the descrption
    end -- Check if the user provided imagte settings
  end -- If there was a description block, check to see if is a settings block

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-4: Extract image settings & description from the ditaa block
  --   fun-? sec-4 sub-1: Extract & remove pandoc-crossref tag
  --   fun-? sec-4 sub-2: Extract & remove image description from ditaa block
  --   fun-? sec-4 sub-3: Remove blank lines / only white space lines at end
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  --**************************************************************************
  -- Fun-? Sec-4 Sub-1: Extract & remove image settings from ditaa block
  --**************************************************************************

  if nextNewLineInt == nil and -- No new line after mage settings block
     crossRefTagStartInt and       -- Image setting block has an start
     crossRefTagEndInt             -- Image setting block has an end
  then
  -- If there are image settings to pull out

    crossRefTagStartInt =
      string.find(
        codeBlockObj.text,  -- Test to look for pandoc-crossref tag in
        "fig:",             -- Tag (diagram is only ever a figure)
        crossRefTagStartInt -- Starting point to look
    ); -- Find if the user provided a pandoc-crossref tag

    if crossRefTagStartInt then
    -- if there is a pandoc-crossref tag to extract
      crossRefTagEndInt =
        string.find(
          codeBlockObj.text,  -- string look for end of pandoc-crossref tag in
           "[ \t\n\r}]",      -- End crossref tag block, at this point } exits
          crossRefTagStartInt -- Starting point of pandoc-crossref tag
       ); -- Find if the end of the user provided a pandoc-crossref tag

      crossRefTagStr =
        string.sub(          --pull out {.*} substring at end
          codeBlockObj.text, -- string to graph ending {.*} from
          crossRefTagStartInt,  -- starting index pointing to {
          crossRefTagEndInt - 1 -- ending index pointing to }
      ); -- Grab the user provided image setting;
    end -- if there is a pandoc-crossref tag to extract

    codeBlockObj.text =    -- It would be better to do at end, but this works
      string.sub(          -- removed {.*} substring at end
        codeBlockObj.text, -- string to graph ending {.*} from
        1,                 -- First charcter in string
        crossRefTagStartInt - 1   -- starting index pointing to {
    ); -- Remove the image settings from the string
  end -- If there are image settings to pull out

  --**************************************************************************
  -- Fun-? Sec-4 Sub-2: Extract & remove image description from ditaa block
  --**************************************************************************

  -- Get the description
  if nextNewLineInt == nil and  -- If there is not new line afer user block
     descStartInt and            -- User description block has an start
     descEndInt                  -- User descrption block has an end
  then
  -- if there is a a description to pull out

    descStr =
      string.sub(
        codeBlockObj.text,  -- string to grab [.*] at end from
        descStartInt,       -- starting point of last [
        descEndInt          -- ending point of last ]
    ); -- Get the description substring

    descStr = 
      string.gsub(     -- gsub to replace all occurnces of new lines
        descStr,       -- String to remove newlines "\n" from
        "\n",          -- character to replace (new line)
        " "            -- replace new lines with spaces
    ); -- In case user added new lines (need to remove)

    codeBlockObj.text =    -- It would be better to do at end, but this works
      string.sub(          -- removed [.*] substring at end
        codeBlockObj.text, -- string to graph ending [.*] from
        1,                 -- First charcter in string
        descStartInt - 1   -- starting index pointing to [
    ); -- Remove the image settings from the string
  end -- if there is a a description to pull out

  --************************************************************************
  -- Fun-? Sec-4 Sub-3: Remove blank lines / only white space lines at end
  --************************************************************************

  codeBlockObj.text = 
    string.gsub(
      codeBlockObj.text,  -- String to trim ending white space from
      "[ \t\n\r]*$",      -- white space to trim ($ means end of string)
      ""                  -- replace white space with noting
  ); -- Remove withe space from the end of the ditaa block

  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- Fun-? Sec-5: Convert image with ditaa
  --   fun-? sec-5 sub-1:
  --   fun-? sec-5 sub-2:
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  if callDitaaStr then

    if string.find(ditaaFileStr, "^ditaa[0-9]*$") then
      ditaaFileStr = ditaaFileStr .. intImageCnt;
    end -- If using default file name, incurment file name for each new diagram

    intImageCnt = intImageCnt + 1;

    callDitaa(
      codeBlockObj.text,                 -- ditaa block string to convert to image
      ditaaFileStr .. '.' .. fileExtStr, -- file name for output png from ditaa
      ditaaParmStr                       -- settings to send to ditaa
    ); -- call ditaa to make my image

  else
    return codeBlockObj; -- Can not call ditaa, Insert ascii digram as codeblock
  end -- If can call ditaa (java binarary callable, ditaa found)

  descStr =
    string.gsub(
      descStr,   -- string to replace [] in
      "^%[",     -- remove [ at start of block (^)
      ""         -- replace with nothing
  ); -- Remove the [] from the description block

  descStr =
    string.gsub(
      descStr,          -- string to replace [] in
      "%][ \t\n\r]*$",  -- remove ] & white space at end ($) of in block
      ""                -- replace with nothing
  ); -- Remove the [] from the description block

  return 
    pandoc.Para(
      pandoc.Image(
        descStr,                           -- description to add to caption
        ditaaFileStr .. "." .. fileExtStr, -- file name to the image to add in
        "fig:",                            -- title (tells pandoc is a figure)
        crossRefTagStr                     -- tag for pandoc crossref to catch
  )); -- return the image
end -- CodeBlock function

return{
  {Meta = Meta},             -- Call the meta function first
  {CodeBlock = CodeBlock},   -- Run codeblock second
}
