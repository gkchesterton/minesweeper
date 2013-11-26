class Board
  attr_reader :tile_grid

  def initialize
    @tile_grid = Array.new(9) { Array.new(9) { Tile.new() } }
    set_bombs
    set_tile_coords
  end

  def set_tile_coords
    @tile_grid.each_with_index do |row, r_index|
      row.each_with_index do |tile, c_index|
        tile.coords = [r_index, c_index]
        tile.neighbor_bombs = neighbor_bombs(tile)
      end
    end
  end

  def make_move(move)
    move_type, coords = move
    coords.reverse!
    move_type == "f" ? flag_coords(coords) : reveal_contig(coords)
  end

  def set_bombs(no_of_bombs = 9)
    total_bombs = 0
    until total_bombs == no_of_bombs do
      tile = @tile_grid.sample.sample
      total_bombs += 1 unless tile.bomb?
      tile.bomb = true
    end
  end

  def get_tile(coords)
    x,y = coords
    @tile_grid[x][y]
  end

  def adjacent_tiles(coords)
    coords_x, coords_y = coords
    neighbor_offsets =
        [[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0]]
    # [-1, 0, 1].product([-1, 0, 1])
    [].tap do |neighbors|
      neighbor_offsets.each do |offset_x,offset_y|
        next unless (coords_x + offset_x).between?(0,8)
        next unless (coords_y + offset_y).between?(0,8)
        neighbors << @tile_grid[coords_x + offset_x][coords_y + offset_y]
      end
    end
  end

  def print
    @tile_grid.each do |row|
      puts row.join(" ")
    end
  end

  def to_s
    @tile_grid.map { |row| row.join(" ") }.join("\n")
  end

  def won?
    @tile_grid.all? do |row|
      row.all? { |tile| tile.revealed? || tile.bomb? }
    end
  end

  def reveal_contig(coords)
    reveal_queue = [get_tile(coords)]
    until reveal_queue.empty?
      current_tile = reveal_queue.shift
      current_tile.reveal
      return false if current_tile.bomb?
      if current_tile.neighbor_bombs == 0
        adjacent_tiles(current_tile.coords).each do |tile|
          reveal_queue << tile unless tile.revealed?
        end
      end
    end
    true
  end

  def flag_coords(coords)
    get_tile(coords).flag
  end

  def neighbor_bombs(tile)
    adjacent_tiles(tile.coords).count do |tile|
      tile.bomb?
    end
  end
end