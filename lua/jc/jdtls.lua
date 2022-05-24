local M = {}

local function choose_imports(params, _)
    local prompt = "Choose candidate:\n"
    for i, candidate in ipairs(params.arguments[2][1].candidates) do
        print(vim.inspect(candidate))
        prompt = prompt .. i .. '. '.. candidate.fullyQualifiedName .. '\n'
    end
    local choice = tonumber(vim.fn.input(prompt.. "Your choice: "))

    return {params.arguments[2][1].candidates[choice]}
end

local function set_configuration(settings)
    vim.lsp.buf_request(0, 'workspace/didChangeConfiguration', {
        settings = settings}, function () end)
end

local client_commands = {
    ['java.action.organize_imports.chooseImports'] = choose_imports
}

vim.lsp.handlers['workspace/executeClientCommand'] = function(_, params, ctx)
    if client_commands[params.command] ~= nil then
        return client_commands[params.command](params, ctx)
    end

    return ''
end

function M.generate_hashCodeAndEquals(fields)
    if not fields then
        vim.lsp.buf_request(0, 'java/checkHashCodeEqualsStatus', vim.lsp.util.make_range_params(), function (e, r)
            if r then
                vim.fn['generators#GenerateHashCodeAndEquals'](r.fields)
            else
                vim.log(vim.inspect(e), vim.log.levels.ERROR)
            end
        end)
    else
        set_configuration({
            ['java.codeGeneration.insertionLocation'] = 'lastMember' })

        vim.lsp.buf_request(0, 'java/generateHashCodeEquals', {
            context = vim.lsp.util.make_range_params(),
            fields = fields,
            regenerate = true},
            function (e, r)
                if not e then
                    vim.lsp.util.apply_workspace_edit(r, 'utf-16')
                else
                    vim.log(vim.inspect(e), vim.log.levels.ERROR)
                end
            end)
    end
end

function M.generate_toString(fields, params)
    if not fields then
        vim.lsp.buf_request(0, 'java/checkToStringStatus', vim.lsp.util.make_range_params(), function (e, r)
            if r then
                vim.fn['generators#GenerateToString'](r.fields)
            else
                vim.log(vim.inspect(e), vim.log.levels.ERROR)
            end
        end)
    else
        set_configuration({
            ['java.codeGeneration.toString.codeStyle'] = params.code_style,
            ['java.codeGeneration.insertionLocation'] = 'lastMember' })

        vim.lsp.buf_request(0, 'java/generateToString', {
            context = vim.lsp.util.make_range_params(),
            fields = fields},
            function (e, r)
                if not e then
                    vim.lsp.util.apply_workspace_edit(r, 'utf-16')
                else
                    vim.log(vim.inspect(e), vim.log.levels.ERROR)
                end
            end)
    end
end

function M.organize_imports()
    vim.lsp.buf_request(0, 'java/organizeImports', vim.lsp.util.make_range_params(), function (e, r)
        if not e then
            vim.lsp.util.apply_workspace_edit(r, 'utf-16')
        else
            vim.log(vim.inspect(e), vim.log.levels.ERROR)
        end
    end)
end

return M
