package newestfile.here.newestplugin;

import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.nio.charset.StandardCharsets;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.io.File;
import org.bukkit.event.player.PlayerQuitEvent;
import org.bukkit.entity.Player;
import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.World;
import org.bukkit.block.Block;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.event.player.PlayerMoveEvent;
import org.bukkit.Bukkit;
import org.bukkit.event.Listener;
import org.bukkit.event.block.Action;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.scheduler.BukkitRunnable;
import org.bukkit.scheduler.BukkitTask;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.LeatherArmorMeta;
import org.bukkit.event.EventHandler;
import java.nio.file.Files; 
import org.bukkit.ChatColor;
import org.bukkit.Color;
import java.util.Random;

@SuppressWarnings("deprecation")
public class Main extends JavaPlugin implements Listener
{
	private HashMap <UUID, BukkitTask> tasks = new HashMap<>();
    private File dataFolder;
    private List<Player> activePlayers; 
    private List<Location> Follow1;
    private boolean isListActive = false;
    private static final Random RANDOM = new Random();

        private static final Location[] PREY_LOCATIONS = {
    	    new Location(Bukkit.getWorld("world"), 40, -58, 75),
    	    new Location(Bukkit.getWorld("world"), 39, -58, 55),
    	    new Location(Bukkit.getWorld("world"), 2, -58, 55),
    	    new Location(Bukkit.getWorld("world"), 3, -58, 75)
    	};

        private static final Location[] PRED1_LOCATIONS = {
        	new Location(Bukkit.getWorld("world"), 30, -58, 66),
        	new Location(Bukkit.getWorld("world"), 29, -58, 60),
        	new Location(Bukkit.getWorld("world"), 6, -58, 50),
        	new Location(Bukkit.getWorld("world"), 6, -58, 30)
        };

        private static final Location[] PRED2_LOCATIONS = {
            new Location(Bukkit.getWorld("world"), 35, -58, 67),
        	new Location(Bukkit.getWorld("world"), 34, -58, 67),
        	new Location(Bukkit.getWorld("world"), 13, -58, 54),
        	new Location(Bukkit.getWorld("world"), 15, -58, 72)
        	};
        
    	public void teleportCharacters(Player prey, Player pred1, Player pred2) {
    	    int setIndex = RANDOM.nextInt(4); 
    	    Location preyLocation = PREY_LOCATIONS[setIndex];
    	    prey.teleport(preyLocation);
    	    Location pred1Location = PRED1_LOCATIONS[setIndex];
    	    pred1.teleport(pred1Location);
    	    Location pred2Location = PRED2_LOCATIONS[setIndex];
    	    pred2.teleport(pred2Location);
    	}	
    
    public void onEnable() {
        Bukkit.getServer().getPluginManager().registerEvents(this,this);
        activePlayers = new ArrayList<>(); 
        Follow1 = new ArrayList<>(); 
        isListActive = false; 
        getLogger().info("HELLO! WELCOME TO THE TRACKER PLUGIN");
        dataFolder = new File(getDataFolder(), "newdata"); 
        dataFolder.mkdirs();
    }

    @EventHandler 
    public void onLogin(final PlayerJoinEvent event) {
        final Player thePlayer = event.getPlayer(); 
        final Location playerSpawnLocation = thePlayer.getLocation();
        getLogger().info("Welcome " + thePlayer.getName() + ". Your current position is: " + playerSpawnLocation);  
        BukkitTask task = getServer().getScheduler().runTaskTimer(this, () ->
        logToFile(thePlayer, thePlayer.getLocation()), 0L, 20L);
        tasks.put(thePlayer.getUniqueId(),task);
      }
 
    @EventHandler 
    public void onQuit(final PlayerQuitEvent event) {
        Player thePlayer = event.getPlayer();
        if(!thePlayer.isOnline()) {
            getLogger().info(String.valueOf(event.getPlayer().getName()) + " has left the game");
            BukkitTask task = tasks.remove(thePlayer.getUniqueId());
            if(task != null) {
               task.cancel();
            }
        }
    }
    
    private void logToFile(final Player currentPlayer, final Location playerCurrentLocation) {
        double distance = 0;
        int bin = 0;
        double distance2 = 0;
        int bin2 = 0;
        double distance3 = 0;
        int bin3 = 0;

        Player targetPlayer = Bukkit.getPlayer("anna232224");
        if (targetPlayer != null) {
            distance = playerCurrentLocation.distance(targetPlayer.getLocation());
            bin = getBin(distance);
        } 
        
        Player targetPlayer2 = Bukkit.getPlayer("TwentyPoet26227");
        if (targetPlayer2 != null) {
            distance2 = playerCurrentLocation.distance(targetPlayer2.getLocation());
            bin2 = getBin(distance2);
        } 
        
        Player targetPlayer3 = Bukkit.getPlayer("caledonian26");
        if (targetPlayer3 != null) {
            distance3 = playerCurrentLocation.distance(targetPlayer3.getLocation());
            bin3 = getBin(distance3);
        } 
        
        String playerName = currentPlayer.getName();
        String content = generateLogContent(currentPlayer, playerCurrentLocation, distance, bin, distance2, bin2, distance3, bin3);
        saveLogToFile(playerName, content);
    }

    private int getBin(double distance) {
        int[] binValues = new int[]{5, 10, 15, 20, 25};
        int[] radiusValues = new int[]{5, 10, 15, 20, Integer.MAX_VALUE};
        for (int i = 0; i < radiusValues.length; i++) {
            if (distance <= radiusValues[i]) {
                return binValues[i];
            }
        }
        return 0; 
    }

    private String generateLogContent(Player currentPlayer, Location playerCurrentLocation, double distance, int bin, 
                                      double distance2, int bin2, double distance3, int bin3) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
        String timestamp = sdf.format(new Date());
        return timestamp + " CurrentLocation(x,y,z): " + playerCurrentLocation.getBlockX() + " " + playerCurrentLocation.getBlockY() 
               + " " + playerCurrentLocation.getBlockZ() + " Distance to anna232224 (prey): " + distance + " Distance to anna232224 (prey) bin: "
               + bin + " Distance to other predator 1: " + distance2 + " Distance to other predator 1 bin: " + bin2 
               + " Distance to other predator 2: " + distance3 + " Distance to other predator 2 bin: " + bin3 
               + " Current Yaw: " + currentPlayer.getEyeLocation().getYaw() + " Current Pitch: " + currentPlayer.getEyeLocation().getPitch()
               + " Heading Direction: " + currentPlayer.getEyeLocation().getDirection() + "\n";
    }

    private void saveLogToFile(String playerName, String content) {
        try {
            fileNameSuffix = "here";   
            final File file = new File(dataFolder, playerName + "_" + String.valueOf(new SimpleDateFormat("dd-MM-yyyy").format(new Date())) + fileNameSuffix + ".log");
            if (!file.exists()) {
                file.createNewFile();
            }
            Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
     
    List<String> vowels = new ArrayList<>();
    List<String> vowels2 = new ArrayList<>();
    
    private  Map<String, Long> buttonPressTimes = new HashMap<>();
    Player otherPlayer;
    BukkitTask grouppracticeChaseRunnable = null;
    BukkitTask grouppracticeFollowRunnable = null;
    BukkitTask groupFollowJUMP = null;
    BukkitTask pred1FOLLOWJUMP = null;
    BukkitTask pred2FOLLOWJUMP = null;

    Player damagedPlayer = null; 
    private String fileNameSuffix;
    private String trialtype;

    HashMap<String, Integer> playerClicks1 = new HashMap<>();
    HashMap<String, Integer> playerClicks2 = new HashMap<>();

    private void dressPlayerAndPlaceItems(Player player, String trial, String color, String inventorycolor) {
        player.getInventory().setArmorContents(new ItemStack[]{null, null, null, null});
        player.getInventory().clear();
        ItemStack chestplate = new ItemStack(Material.LEATHER_CHESTPLATE);
        LeatherArmorMeta chestplateMeta = (LeatherArmorMeta) chestplate.getItemMeta();
        switch (color.toLowerCase()) {
            case "blue":
                chestplateMeta.setColor(Color.fromRGB(0, 0, 255));
                chestplate.setItemMeta(chestplateMeta);
                break;
            case "white":
                chestplateMeta.setColor(Color.fromRGB(192, 192, 192));
                chestplate.setItemMeta(chestplateMeta);
                break;
            case "light green":
                chestplateMeta.setColor(Color.fromRGB(144, 238, 144)); 
                chestplate.setItemMeta(chestplateMeta);
                break;
            default:
                player.sendMessage("Invalid color specified!");
                return;
        }
        if (trial.equalsIgnoreCase("groupfollow") || trial.equalsIgnoreCase("groupchase")) {
            player.getInventory().setChestplate(chestplate); 
        }
        ItemStack inventoryChestplate = new ItemStack(Material.LEATHER_CHESTPLATE);
        LeatherArmorMeta inventoryChestplateMeta = (LeatherArmorMeta) inventoryChestplate.getItemMeta();
        switch (inventorycolor.toLowerCase()) {
        case "blue":
            inventoryChestplateMeta.setColor(Color.fromRGB(0, 0, 255));
            break;
        case "white":
            inventoryChestplateMeta.setColor(Color.fromRGB(192, 192, 192));
            break;
        default:
            player.sendMessage("Invalid inventory color specified!");
            return;
        }
        inventoryChestplate.setItemMeta(inventoryChestplateMeta);
        player.getInventory().addItem(inventoryChestplate);
        }

    private void replaceBlocksWithAir1() {
        int[][] coordinatesToReplace1 = {
            {49, -58, 64}, {7, -58, 42}, {16, -58, 70}, {53, -58, 86}
        };
        for (Player player : Bukkit.getServer().getOnlinePlayers()) {
            String playerName = player.getName();
            if (playerName.equals("TwentyPoet26227")) {
                World world = player.getWorld();
                if (world != null) {
                    for (int[] coord : coordinatesToReplace1) {
                        int x = coord[0];
                        int y = coord[1];
                        int z = coord[2];
                        Location loc = new Location(world, x, y, z);
                        Block block = loc.getBlock();
                        block.setType(org.bukkit.Material.AIR);
                    }
                }
            }
        }
    }

    private static final long COOLDOWN_DURATION = 2000;

    BukkitTask task2a = null;
    BukkitTask task2b = null;
    Player playerclick;

    @EventHandler
    public void onPlayerMove(PlayerMoveEvent event) {
        Player player = event.getPlayer();
        if (activePlayers.contains(player) && isListActive) {
            Block block = player.getLocation().getBlock();
            if (!Follow1.contains(block.getLocation())) { 
                Follow1.add(block.getLocation());
                try {
                    fileNameSuffix = "here";   
                    String content = String.valueOf(new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) +
                            " Player: " + event.getPlayer().getName() +
                            " Location: " + event.getPlayer().getLocation();
                    final File file = new File(dataFolder, "TESTFOLLOWROUTES" + event.getPlayer().getName() +
                            String.valueOf(new SimpleDateFormat("dd-MM-yyyy").format(new Date())) + fileNameSuffix + ".log");
                    if (!file.exists()) {
                        file.createNewFile();
                    }
                    Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
		   
   @EventHandler
   public void onPlayerInteract(PlayerInteractEvent event) {  
	       Block clickedBlock = event.getClickedBlock();
	       if (clickedBlock == null) {
	           return; 
	       }
    	    	   
        	if (event.getClickedBlock() != null && event.getAction() == Action.RIGHT_CLICK_BLOCK && event.getClickedBlock().getType() == Material.WARPED_BUTTON) {
        	    if (event.getPlayer().getName().equals("caledonian26")) {
        	        trialtype = "groupchase";
        	        Player tao = Bukkit.getPlayer("anna232224");
        	        Player emre = Bukkit.getPlayer("caledonian26");
        	        Player anna = Bukkit.getPlayer("TwentyPoet26227");
        	        int setIndex = RANDOM.nextInt(4);
        	        for (Player player : Bukkit.getServer().getOnlinePlayers()) {
        	        	player.sendTitle("Keep still!","Look at me jump!", 10, 70, 20);
        	        }

        	        if (emre != null) {
        	        	Location preyLocation = PREY_LOCATIONS[setIndex];
        	            World world = emre.getWorld();
        	            Location emreLocation = new Location(world, preyLocation.getX(), preyLocation.getY(), preyLocation.getZ());
        	            dressPlayerAndPlaceItems(emre, "groupchase", "blue","blue");
        	            emre.teleport(emreLocation);
        	        }

        	        if (anna != null) {
        	        	Location pred1Location = PRED1_LOCATIONS[setIndex]; // Optionally randomize index inside the set
        	            World world = anna.getWorld();
        	            Location annaLocation = new Location(world, pred1Location.getX(), pred1Location.getY(), pred1Location.getZ());
        	            dressPlayerAndPlaceItems(anna, "groupchase","light green","blue");
        	            anna.teleport(annaLocation);
        	        }

        	        if (tao != null) {
        	        	Location pred2Location = PRED2_LOCATIONS[setIndex]; // Optionally randomize index inside the set
        	            World world = tao.getWorld();
        	            Location taoLocation = new Location(world, pred2Location.getX(), pred2Location.getY(), pred2Location.getZ());
        	            dressPlayerAndPlaceItems(tao, "groupchase","light green","blue");
        	            tao.sendMessage("The next trial is a group hunt.");
        	            tao.teleport(taoLocation);
        	        }
        	        new BukkitRunnable() {
        	            @Override
        	            public void run() {
        	                Player emre = Bukkit.getPlayer("caledonian26");
        	                if (emre != null && emre.isOnline()) {
        	                    emre.sendMessage("30 seconds has passed.");
        	                }
        	            }
        	        }.runTaskLater(this, 600);
        	    }
        	}

        	if (event.getClickedBlock() != null && event.getAction() == Action.RIGHT_CLICK_BLOCK && event.getClickedBlock().getType() == Material.CRIMSON_BUTTON) {
        	    if (event.getPlayer().getName().equals("caledonian26")) {
        	        trialtype = "groupfollow";
        	        Player tao = Bukkit.getPlayer("anna232224");
        	        Player emre = Bukkit.getPlayer("caledonian26");
        	        Player anna = Bukkit.getPlayer("TwentyPoet26227");
        	        int setIndex = RANDOM.nextInt(4);
            	    for (Player player : Bukkit.getServer().getOnlinePlayers()) {
            	            player.sendTitle("Keep still!","Look at me jump!", 10, 70, 20);
            	    }

        	        if (emre != null) {
        	        	Location preyLocation = PREY_LOCATIONS[setIndex];
        	            World world = emre.getWorld();
        	            Location emreLocation = new Location(world, preyLocation.getX(), preyLocation.getY(), preyLocation.getZ());
        	            dressPlayerAndPlaceItems(emre, "groupfollow", "white","white");      	           
        	            emre.teleport(emreLocation);
        	        }

        	        if (anna != null) {
        	        	Location pred1Location = PRED1_LOCATIONS[setIndex]; // Optionally randomize index inside the set
        	            World world = anna.getWorld();
        	            Location annaLocation = new Location(world, pred1Location.getX(), pred1Location.getY(), pred1Location.getZ());
        	            dressPlayerAndPlaceItems(anna, "groupfollow","light green","white");
                        anna.teleport(annaLocation);
        	        }

        	        if (tao != null) {
        	        	Location pred2Location = PRED2_LOCATIONS[setIndex]; // Optionally randomize index inside the set
        	            World world = tao.getWorld();
        	            Location taoLocation = new Location(world, pred2Location.getX(), pred2Location.getY(), pred2Location.getZ());
        	            dressPlayerAndPlaceItems(tao, "groupfollow","light green","white");
        	            tao.sendMessage("The next trial is a group follow.");
        	            tao.teleport(taoLocation);
        	        }
        	        new BukkitRunnable() {
        	            @Override
        	            public void run() {
        	                Player emre = Bukkit.getPlayer("caledonian26");
        	                if (emre != null && emre.isOnline()) {
        	                    emre.sendMessage("30 seconds has passed.");
        	                }
        	            }
        	        }.runTaskLater(this, 600);
        	    }
        	}      
        	        	
        	if (event.getClickedBlock() != null && event.getClickedBlock().getType() == Material.SPRUCE_BUTTON) {
        	    if (event.getPlayer().getName().equals("caledonian26")) {
        	    	Player anna = Bukkit.getPlayer("TwentyPoet26227");
        	    	if (anna != null && anna.isOnline()) {
        	    		int x = ThreadLocalRandom.current().nextInt(2, 11);
        	    		String title = "Well done!";
        	            String subtitle = "You caught the prey " + x + " times";
        	            anna.sendTitle(title, subtitle, 10, 70, 20);
    	            }
        	    }
        	}

        	if (event.getClickedBlock() != null && event.getClickedBlock().getType() == Material.STRIPPED_ACACIA_WOOD) {
        	    playerClicks2.clear();
        	    if (grouppracticeChaseRunnable != null) {
        	        grouppracticeChaseRunnable.cancel();
        	    }
        	    if (grouppracticeFollowRunnable != null) {
        	        grouppracticeFollowRunnable.cancel();
        	    }
        	    if (groupFollowJUMP != null) {
        	        groupFollowJUMP.cancel();
        	    }
        	    if (pred1FOLLOWJUMP != null) {
        	        pred1FOLLOWJUMP.cancel();
        	    }
        	    if (pred2FOLLOWJUMP != null) {
        	        pred2FOLLOWJUMP.cancel();
        	    }
        	    if (event.getPlayer().getName().equals("caledonian26")) {
        	        try {
        	            fileNameSuffix = "here";   
        	            String content = String.valueOf(new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) +
        	                    " Player: " + event.getPlayer().getName() +
        	                    " Location: " + event.getPlayer().getLocation() +
        	                    " Material: " + event.getClickedBlock().getType() + "\n";
        	            final File file = new File(dataFolder, "eventsworldtour" + event.getPlayer().getName() +
        	                    String.valueOf(new SimpleDateFormat("dd-MM-yyyy").format(new Date())) + fileNameSuffix + ".log");
        	            if (!file.exists()) {
        	                file.createNewFile();
        	            }
        	            Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        	        } catch (Exception e) {
        	            e.printStackTrace();
        	        }
        	    }
        	}

        	if (event.getClickedBlock() != null && event.getClickedBlock().getType() == Material.OAK_WOOD) {
        	    replaceBlocksWithAir1();
        	    playerClicks2.clear();
        	    if (grouppracticeChaseRunnable != null) {
        	        grouppracticeChaseRunnable.cancel();
        	    }
        	    if (grouppracticeFollowRunnable != null) {
        	        grouppracticeFollowRunnable.cancel();
        	    }
        	    if (groupFollowJUMP != null) {
        	        groupFollowJUMP.cancel();
        	    }
        	    if (pred1FOLLOWJUMP != null) {
        	        pred1FOLLOWJUMP.cancel();
        	    }
        	    if (pred2FOLLOWJUMP != null) {
        	        pred2FOLLOWJUMP.cancel();
        	    }
        	    event.getPlayer().sendTitle("Runnables reset!", "", 10, 70, 20);
        	}
        	
        	if (event.getClickedBlock() != null && event.getClickedBlock().getType() == Material.CHERRY_BUTTON) {
        		Player player = event.getPlayer();
        		Player emre = Bukkit.getPlayer("caledonian26");
        		Player anna = Bukkit.getPlayer("anna232224");
        		Player poet = Bukkit.getPlayer("TwentyPoet26227");
        		if (emre != null && emre.isOnline()) {
        		    emre.sendTitle("Starting soon!", "Keep still", 10, 70, 20);
        		}

        		if (anna != null && anna.isOnline()) {
        		    anna.sendTitle("Starting soon!", "Keep still", 10, 70, 20);
        		}

        		if (poet != null && poet.isOnline()) {
        		    poet.sendTitle("Starting soon!", "Keep still", 10, 70, 20);
        		}
    	    if (player.getName().equalsIgnoreCase("caledonian26")) {
    	    	player.setWalkSpeed(0.2f);
                new BukkitRunnable() {
                    @Override
                    public void run() {
                    	float randomSpeedVariation = 0.1f + (RANDOM.nextFloat() * 0.3f);
                        player.setWalkSpeed(randomSpeedVariation);
                    }
                }.runTaskTimer(this, 100L, 100L); 
            }
        	}
        	
        	if (event.getClickedBlock() != null && event.getClickedBlock().getType() == Material.STRIPPED_OAK_WOOD) {
        	    Player player = event.getPlayer();         	    
        	        if (grouppracticeChaseRunnable != null) {
        	            grouppracticeChaseRunnable.cancel();
        	        }
        	        if (grouppracticeFollowRunnable != null) {
        	            grouppracticeFollowRunnable.cancel();
        	        }
        	        Player emre = Bukkit.getPlayer("caledonian26");
        	        World world = emre.getWorld();
        	        int setIndex = RANDOM.nextInt(4);
        	        Player anna = Bukkit.getPlayer("anna232224");
        	        if (anna != null && anna.isOnline()) {
        	            anna.sendTitle("Time up!", "Stop Moving.", 10, 20, 10);
        	            Location pred1Location = PRED1_LOCATIONS[setIndex]; 
        	            Location annaLocation = new Location(world, pred1Location.getX(), pred1Location.getY(), pred1Location.getZ());     	        
            	        anna.teleport(annaLocation);
        	        }
        	        Player poet = Bukkit.getPlayer("TwentyPoet26227");
        	        if (poet != null && poet.isOnline()) {
        	            poet.sendTitle("Time up!", "Stop Moving.", 10, 20, 10);
        	            Location pred2Location = PRED2_LOCATIONS[setIndex]; 
        	            Location poetLocation = new Location(world, pred2Location.getX(), pred2Location.getY(), pred2Location.getZ());
            	        poet.teleport(poetLocation);
        	        }       	        
        	        Location preyLocation = PREY_LOCATIONS[setIndex];  	            
    	            Location emreLocation = new Location(world, preyLocation.getX(), preyLocation.getY(), preyLocation.getZ());  	            
        	        emre.teleport(emreLocation);
        	        player.sendTitle(ChatColor.YELLOW + "END FOR YOU!", ChatColor.WHITE + " ", 10, 100, 10);
        	    long currentTime = System.currentTimeMillis();
        	    String playerName = player.getName();
        	    long buttonPressTime = buttonPressTimes.get(playerName);
        	    long timeDifferenceInSeconds = (currentTime - buttonPressTime) / 1000;
        	    if (player.getName().equals("caledonian26")) {
        	        if (trialtype.equals("groupchase")) {
        	            fileNameSuffix = "here";       	            
        	            try {
        	                String content = String.valueOf("End of chase:" + " " + new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) + "\n" +
        	                        "Prey: " + player.getName() + "\n" +
        	                        " Time taken to catch prey: " + timeDifferenceInSeconds + "\n" +
        	                        " Location: " + player.getLocation() + "\n";
        	                final File file = new File(dataFolder, "eventspracticegroupchasepart" + "anna232224" +
        	                        String.valueOf(new SimpleDateFormat("dd-MM-yyyy").format(new Date())) + fileNameSuffix + ".log");
        	                if (!file.exists()) {
        	                    file.createNewFile();
        	                }
        	                Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        	            } catch (Exception e) {
        	                e.printStackTrace();
        	            }
        	        }
        	        else if (trialtype.equals("groupfollow")) {
        	            fileNameSuffix = "here";         	            
        	            try {
        	                String content = String.valueOf("End of follow:" + " " + new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) + "\n" +
        	                        "Prey: " + player.getName() + "\n" +
        	                        " Length of trial: " + timeDifferenceInSeconds + "\n" +
        	                        " Location: " + player.getLocation() + "\n";
        	                final File file = new File(dataFolder, "eventspracticegroupfollowpart" + "anna232224" +
        	                        String.valueOf(new SimpleDateFormat("dd-MM-yyyy").format(new Date())) + fileNameSuffix + ".log");
        	                if (!file.exists()) {
        	                    file.createNewFile();
        	                }
        	                Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        	            } catch (Exception e) {
        	                e.printStackTrace();
        	            }
        	        }
        	    }
        	}
    	    
        	if (event.getClickedBlock() != null && event.getClickedBlock().getType() == Material.MOSS_CARPET) {
        		Player playerclick = event.getPlayer();
        		
        	    if (buttonPressTimes.containsKey(playerclick.getName()) &&
        	        System.currentTimeMillis() - buttonPressTimes.get(playerclick.getName()) < COOLDOWN_DURATION) {
        	        return;
        	    }
        	    buttonPressTimes.put(playerclick.getName(), System.currentTimeMillis());

        	    if (event.getPlayer().getName().equals("caledonian26")) {
        	        for (Player player : Bukkit.getServer().getOnlinePlayers()) {
        	            player.sendTitle("Hunt!", "", 10, 20, 10);
        	        }

        	        if (trialtype.equals("groupchase")) {
        	            try {
        	                fileNameSuffix = "here";   
        	                String content = String.valueOf(new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) +
        	                        " Player: " + event.getPlayer().getName() +
        	                        " Location at start of chase: " + event.getPlayer().getLocation() +
        	                        " Material: " + event.getClickedBlock().getType() + "\n";
        	                final File file = new File(dataFolder, "eventspracticegroupchasepart" + "anna232224" +
        	                        String.valueOf(new SimpleDateFormat("dd-MM-yyyy").format(new Date())) + fileNameSuffix + ".log");
        	                if (!file.exists()) {
        	                    file.createNewFile();
        	                }
        	                Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        	            } catch (Exception e) {
        	                e.printStackTrace();
        	            }
        	        }
        	    }
        	}

        	grouppracticeChaseRunnable = new BukkitRunnable() {
        	    public void run() {
        	        if (event.getClickedBlock().getType() == Material.MOSS_CARPET && trialtype.equals("groupchase")) {
        	            for (Player player : Bukkit.getServer().getOnlinePlayers()) {
        	                String playerName = player.getName();
        	                if (playerName.equals("caledonian26")) {
        	                    for (Player onlinePlayer : Bukkit.getServer().getOnlinePlayers()) {
        	                        onlinePlayer.sendTitle("Time up!", "Stop Moving.", 10, 20, 10);
        	                    }
        	                    fileNameSuffix = "here";   
        	                    try {
        	                        String content = String.valueOf("End of chase:" + " " + new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) +
        	                                " Time taken to catch prey: " + "No prey caught on this trial" + "\n";
        	                        final File file = new File(dataFolder, "eventspracticegroupchasepart" + "anna232224" +
        	                                String.valueOf(new SimpleDateFormat("dd-MM-yyyy").format(new Date())) + fileNameSuffix + ".log");
        	                        if (!file.exists()) {
        	                            file.createNewFile();
        	                        }
        	                        Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        	                    } catch (Exception e) {
        	                        e.printStackTrace();
        	                    }
        	                }
        	            }
        	        }
        	    }
        	}.runTaskLater(this, 1200);

        	new BukkitRunnable() {
        	    public void run() {
        	        if (!event.getPlayer().isOnline()) {
        	            grouppracticeChaseRunnable.cancel();
        	            this.cancel();
        	        }
        	        if (event.getPlayer().isDead()) {
        	            grouppracticeChaseRunnable.cancel();
        	            this.cancel();
        	        }
        	    }
        	}.runTaskTimer(this, 0, 1);
    
        	if (event.getClickedBlock() != null && event.getClickedBlock().getType() == Material.BROWN_CARPET) {
        	    Player playerclick = event.getPlayer();

        	    if (buttonPressTimes.containsKey(playerclick.getName()) &&
        	            System.currentTimeMillis() - buttonPressTimes.get(playerclick.getName()) < COOLDOWN_DURATION) {
        	            return;
        	        }
        	    buttonPressTimes.put(playerclick.getName(), System.currentTimeMillis());

        	    if (playerclick.getName().equals("caledonian26")) {
        	        for (Player Player : Bukkit.getServer().getOnlinePlayers()) {
        	            Player.sendTitle("Follow!", "", 10, 20, 10);
        	        }

        	        if (trialtype.equals("groupfollow")) {
        	            try {
        	                fileNameSuffix = "here";   
        	                String content = String.valueOf(new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) +
        	                        " Player: " + playerclick.getName() +
        	                        " Location at start of follow: " + playerclick.getLocation() +
        	                        " Material: " + event.getClickedBlock().getType() + "\n";
        	                final File file = new File(dataFolder, "eventspracticegroupfollowpart" + "anna232224" +
        	                        new SimpleDateFormat("dd-MM-yyyy").format(new Date()) + fileNameSuffix + ".log");
        	                if (!file.exists()) {
        	                    file.createNewFile();
        	                }
        	                Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        	            } catch (Exception e) {
        	                e.printStackTrace();
        	            }
        	        }
        	    }
        	}

        	grouppracticeFollowRunnable = new BukkitRunnable() {
        	    public void run() {
        	        if (event.getClickedBlock().getType() == Material.BROWN_CARPET && trialtype.equals("groupfollow")) {
        	            for (Player player : Bukkit.getServer().getOnlinePlayers()) {
        	                String playerName = player.getName();
        	                if (playerName.equals("caledonian26")) {
        	                    for (Player onlinePlayer : Bukkit.getServer().getOnlinePlayers()) {
        	                        onlinePlayer.sendTitle("Time up!", "Stop Moving.", 10, 20, 10);
        	                    }
        	                    try {
        	                        fileNameSuffix = "here";   
        	                        String content = String.valueOf("Time at end of follow:" + " " + new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())) +
        	                                " Player: " + event.getPlayer().getName() +
        	                                " length of follow: " + 60 + "\n";
        	                        final File file = new File(dataFolder, "eventspracticegroupfollowpart" + "anna232224" +
        	                                new SimpleDateFormat("dd-MM-yyyy").format(new Date()) + fileNameSuffix + ".log");
        	                        if (!file.exists()) {
        	                            file.createNewFile();
        	                        }
        	                        Files.write(file.toPath(), content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        	                    } catch (Exception e) {
        	                        e.printStackTrace();
        	                    }
        	                }
        	            }
        	        }
        	    }
        	}.runTaskLater(this, 1200);

        	new BukkitRunnable() {
        	    public void run() {
        	        if (!event.getPlayer().isOnline()) {
        	            grouppracticeFollowRunnable.cancel();
        	            this.cancel();
        	        }
        	        if (event.getPlayer().isDead()) {
        	            grouppracticeFollowRunnable.cancel();
        	            this.cancel();
        	        }
        	    }
        	}.runTaskTimer(this, 0, 1);
   }
}
                	
    

                   