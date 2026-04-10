vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.md",
  callback = function()
    vim.keymap.set("i", "@", function()
      local fzf = require("fzf-lua")
      local selected_path = nil

      -- カーソル後の単語を fzf の初期クエリにする
      -- 例: "readme.md を見て" の readme.md の前で @ を押すと、readme.md で検索開始
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local after_cursor = line:sub(col + 1)
      local initial_query = after_cursor:match("^(%S+)") or ""

      fzf.files({
        file_icons = false,
        git_icons = false,
        query = initial_query,
        actions = {
          -- ファイル選択時にパスを保存
          ["default"] = function(selected)
            if selected and selected[1] then
              selected_path = fzf.path.entry_to_file(selected[1]).path
            end
          end,
        },
        winopts = {
          -- fzf 終了時（選択 or キャンセル）に呼ばれる
          on_close = function()
            vim.schedule(function()
              if selected_path then
                -- 初期クエリとして使った文字列を削除
                if initial_query ~= "" then
                  local row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
                  local cur_line = vim.api.nvim_get_current_line()
                  local new_line = cur_line:sub(1, cur_col) .. cur_line:sub(cur_col + 1 + #initial_query)
                  vim.api.nvim_set_current_line(new_line)
                end
                vim.api.nvim_put({ "@" .. selected_path .. " " }, "", false, true)
              else
                -- キャンセル時は @ のみ（初期クエリは残す）
                vim.api.nvim_put({ "@" }, "", false, true)
              end

              -- インサートモードに戻る
              vim.defer_fn(function()
                vim.cmd("startinsert!")
              end, 10)
            end)
          end,
        },
      })
    end, { buffer = true, noremap = true })
  end,
})
