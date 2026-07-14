# Easy VPS Setup Guide for Your Smart Workflows

Hey there! Want to make your computer programs super smart and run them on their own, even when your main computer is off? We're going to set up a special computer on the internet, called a **Virtual Private Server (VPS)**, to do just that. Think of it like renting a small, powerful computer in a data center that's always on.

This guide will walk you through setting up your VPS from scratch, so your n8n workflows (the smart programs you want to run) can use cool tools like a web browser (Playwright) and remember things (PostgreSQL database).

Let's get started, step by step, with no confusing detours!

## Step 1: Get Your Internet Computer (VPS)

First, you need to pick a company that rents out these internet computers. Some popular ones are DigitalOcean, Vultr, Linode, or AWS Lightsail. Here’s what to look for:

*   **Location**: Pick one close to you or where your users are. This makes things faster.
*   **Operating System**: Choose **Ubuntu 22.04 LTS** (LTS means Long Term Support, so it's stable for a long time).
*   **Size**: Start with a small one, like 1 CPU, 2GB RAM, and 50GB storage. You can always make it bigger later if your workflows need more power.

Once you've signed up and picked your server, the company will give you an **IP address** (like a phone number for your server) and a **password** (or a special key file) to log in.

## Step 2: Talk to Your New Computer (Connect via SSH)

Now, let's connect to your VPS. You'll use a special program called **SSH** (Secure Shell). It's like a secret, secure phone line to your server.

**On Windows:**

1.  Download and install a program called [PuTTY](https://www.putty.org/).
2.  Open PuTTY. In the `Host Name (or IP address)` field, type your VPS IP address.
3.  Click **Open**. If it asks about a security alert, click **Accept**.
4.  A black window will pop up. It will ask for `login as:`. Type `root` and press Enter.
5.  It will then ask for `password:`. Type the password your VPS provider gave you (you won't see anything as you type, that's normal for security) and press Enter.

**On macOS / Linux:**

1.  Open your **Terminal** application.
2.  Type the following command, replacing `your_vps_ip` with your actual VPS IP address, and press Enter:
    ```bash
    ssh root@your_vps_ip
    ```
3.  If it asks `Are you sure you want to continue connecting (yes/no/[fingerprint])?`, type `yes` and press Enter.
4.  It will then ask for `root@your_vps_ip's password:`. Type the password your VPS provider gave you and press Enter.

Congratulations! You're now logged into your VPS. You'll see a command line prompt, usually ending with `#`.

## Step 3: Automated Setup with a Single Script

Instead of running many commands one by one, we've prepared a single script that will automate the entire setup process for n8n, PostgreSQL, Docker, and the Playwright MCP server. This makes the installation much faster and less prone to errors.

First, download the script to your VPS:

```bash
wget https://raw.githubusercontent.com/your_repo/your_script_name.sh -O setup_vps.sh
```

**Note**: You will need to replace `https://raw.githubusercontent.com/your_repo/your_script_name.sh` with the actual URL where you host the `setup_vps.sh` script. For now, you can copy-paste the script content directly into a file on your VPS using `nano setup_vps.sh`.

Before running, you need to make the script executable:

```bash
chmod +x setup_vps.sh
```

Now, you need to edit the script to set your specific domain/IP, PostgreSQL password, and timezone. Open the script with `nano`:

```bash
nano setup_vps.sh
```

Find the following lines near the top of the script and update them with your information:

```bash
N8N_DOMAIN="your_n8n_domain.com" # Replace with your actual domain or VPS IP
POSTGRES_PASSWORD="your_strong_postgres_password" # Replace with a strong password
TIMEZONE="Europe/Berlin" # Replace with your desired timezone, e.g., America/New_York
```

Press `Ctrl+X`, then `Y`, then Enter to save and exit `nano`.

Finally, run the script:

```bash
sudo ./setup_vps.sh
```

The script will take some time to complete. Once it finishes, you will see a success message.

**Important**: After the script finishes, you will need to **log out and log back in** to your VPS for the Docker group changes to take effect. You can do this by typing `exit` and then `ssh root@your_vps_ip` again.

## Step 4: Access Your n8n

After logging back in, open your web browser on your computer and go to:

`http://your_vps_ip:5678`

(Replace `your_vps_ip` with your actual VPS IP address).

You should see the n8n setup screen. Follow the prompts to create your owner account.

## Step 5: Connect n8n to Your Tools

Now that n8n is running, you need to tell it how to talk to your database and the Playwright browser.

**Connect to PostgreSQL:**

1.  In n8n, go to **Credentials** on the left menu.
2.  Click **Add Credential**.
3.  Search for **PostgreSQL** and select it.
4.  Fill in the details:
    *   **Host**: `postgresql` (This is the name of the service in your `docker-compose.yml`)
    *   **Database**: `n8n`
    *   **User**: `n8n`
    *   **Password**: The strong password you set in `docker-compose.yml`.
    *   **Port**: `5432`
5.  Click **Save**.

**Connect to Playwright MCP:**

1.  In your n8n workflow, when you add an **MCP Client** node, you'll need to configure it to connect to the Playwright server.
2.  Since the Playwright MCP server is running on the same VPS, you can usually connect to it using `localhost` or the VPS's internal IP address, depending on how you configure the MCP Client node in n8n (often via stdio if running locally, or via SSE/HTTP if exposed). For this setup, running it via `pm2` makes it available on the system. You might need to configure the MCP Client node to execute the command `mcp-server-playwright` directly if it supports local execution, or set up an SSE bridge if it requires a network connection.

That's it! Your VPS is now set up with n8n, a PostgreSQL database for memory, and a Playwright MCP server for web browsing. You're ready to import your smart workflow JSON and start automating!
