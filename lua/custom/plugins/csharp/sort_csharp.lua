local M = {}

-- Helper function to get node text
local function get_node_text(node, bufnr)
  local start_row, start_col, end_row, end_col = node:range()
  if start_row == end_row then
    local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
    return line:sub(start_col + 1, end_col)
  else
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
    lines[1] = lines[1]:sub(start_col + 1)
    lines[#lines] = lines[#lines]:sub(1, end_col)
    return table.concat(lines, '\n')
  end
end

-- Get the full text of a declaration including its body
local function get_declaration_text(node, bufnr)
  local start_row = node:range()
  local last_child = node:child(node:child_count() - 1)
  local _, _, end_row = last_child:range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  return table.concat(lines, '\n')
end

-- Get the name of a declaration
local function get_declaration_name(node, bufnr)
  local identifier = node:field('name')[1]
  if identifier then
    return get_node_text(identifier, bufnr)
  end
  return ''
end

-- Get the type of declaration (interface, class, etc.)
local function get_declaration_type(node)
  if node:type() == 'class_declaration' then
    return 'class'
  elseif node:type() == 'interface_declaration' then
    return 'interface'
  elseif node:type() == 'struct_declaration' then
    return 'struct'
  elseif node:type() == 'enum_declaration' then
    return 'enum'
  elseif node:type() == 'record_declaration' then
    return 'record'
  end
  return node:type()
end

function M.sort_elements()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Check if tree-sitter is available
  if not vim.treesitter.get_parser(bufnr, 'c_sharp') then
    vim.notify('Tree-sitter C# parser not available. Please install it with :TSInstall c_sharp', vim.log.levels.ERROR)
    return
  end

  -- Get the syntax tree
  local parser = vim.treesitter.get_parser(bufnr, 'c_sharp')
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Collect all top-level declarations
  local declarations = {}
  for node in root:iter_children() do
    local type = get_declaration_type(node)
    if type then
      table.insert(declarations, {
        type = type,
        name = get_declaration_name(node, bufnr),
        text = get_declaration_text(node, bufnr),
        node = node,
      })
    end
  end

  -- Sort declarations
  table.sort(declarations, function(a, b)
    local type_priority = {
      interface = 1,
      class = 2,
      record = 3,
      struct = 4,
      enum = 5,
    }

    if a.type == b.type then
      return a.name < b.name
    else
      return (type_priority[a.type] or 99) < (type_priority[b.type] or 99)
    end
  end)

  -- Create new content
  local new_content = {}

  -- Add sorted declarations
  for i, decl in ipairs(declarations) do
    table.insert(new_content, decl.text)
    if i < #declarations then
      table.insert(new_content, '') -- Add blank line between declarations
    end
  end

  -- Replace buffer content
  local start_row = declarations[1].node:range()
  local last_decl = declarations[#declarations].node
  local _, _, end_row = last_decl:range()

  -- Ensure start_row and end_row are correct
  if start_row > end_row then
    vim.notify("Error: 'start' is higher than 'end'", vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, new_content)

  vim.notify('Sorted ' .. #declarations .. ' declarations', vim.log.levels.INFO)
end

-- Command to call the sorting function
vim.api.nvim_create_user_command('SortCSharp', function()
  M.sort_elements()
end, {})

return M
