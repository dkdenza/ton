#!/bin/bash

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Menu
echo ""
echo -e "${RED}  (\_(\  ${NC}"
echo -e "${RED} (=’ :’) :* ${NC} Script by Mnm Ami"
echo -e "${RED}  (,(”)(”) °.¸¸.• ${NC}"
echo ""
echo -e "MENU SCRIPT ${RED}✿.｡.:* *.:｡✿*ﾟ’ﾟ･✿.｡.:*${NC}"
echo ""
echo -e "|${RED} 1${NC}| ADD NEW CLIENT"
echo -e "|${RED} 2${NC}| CHOOSE AND REMOVE CLIENT"
echo -e "|${RED} 3${NC}| CHECK ALL CLIENT"
echo -e "|${RED} 4${NC}| CHECK CLIENT ONLINE"
echo -e "|${RED} 5${NC}| REMOVE CLIENT EXPIRED"
echo -e "|${RED} 6${NC}| SET TIME REBOOT SERVER"
echo -e "|${RED} 7${NC}| "
echo -e "|${RED} 8${NC}| "
echo -e "|${RED} 9${NC}| "
echo -e "|${RED}10${NC}| UPDATE MENU SCRIPT"
echo ""
read -p "Select a Menu : " MENU

case $MENU in

	1)
		clear
		IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
		if [[ "$IP" = "" ]]; then
			IP=$(wget -qO- ipv4.icanhazip.com)
		fi
		newclient () {

		if [ -e /home/$1 ]; then
			homeDir="/home/$1"
		elif [ ${SUDO_USER} ]; then
			homeDir="/home/${SUDO_USER}"
		else  # if not SUDO_USER, use /root
			homeDir="/root"
		fi

		cp /etc/openvpn/client-template.txt $homeDir/$1.ovpn
		echo "<ca>" >> $homeDir/$1.ovpn
		cat /etc/openvpn/easy-rsa/pki/ca.crt >> $homeDir/$1.ovpn
		echo "</ca>" >> $homeDir/$1.ovpn
		echo "<cert>" >> $homeDir/$1.ovpn
		cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> $homeDir/$1.ovpn
		echo "</cert>" >> $homeDir/$1.ovpn
		echo "<key>" >> $homeDir/$1.ovpn
		cat /etc/openvpn/easy-rsa/pki/private/$1.key >> $homeDir/$1.ovpn
		echo "</key>" >> $homeDir/$1.ovpn
		echo "key-direction 1" >> $homeDir/$1.ovpn
		echo "<tls-auth>" >> $homeDir/$1.ovpn
		cat /etc/openvpn/tls-auth.key >> $homeDir/$1.ovpn
		echo "</tls-auth>" >> $homeDir/$1.ovpn
		}


		read -p "Client name : " -e -i client CLIENT
		cd /etc/openvpn/easy-rsa/
		./easyrsa build-client-full $CLIENT nopass

		newclient "$CLIENT"
		cp /root/$CLIENT.ovpn /home/vps/public_html/
		rm $CLIENT.ovpn
		echo ""
		echo "Client Name : $CLIENT"
#		echo "Expire : $EXP"
		echo "Download Config : $IP:80/$CLIENT.ovpn"
		echo ""
		exit
	;;


	2)
		clear
		NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
		if [[ "$NUMBEROFCLIENTS" = '0' ]]; then
			echo ""
			echo "You have no existing clients."
			echo ""
			exit
		fi
			echo ""
			tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
		if [[ "$NUMBEROFCLIENTS" = '1' ]]; then
			read -p "Select one Client [1]: " CLIENTNUMBER
		else
			read -p "Select one Client [1-$NUMBEROFCLIENTS]: " CLIENTNUMBER
		fi

		CLIENT=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$CLIENTNUMBER"p)
		cd /etc/openvpn/easy-rsa/
		./easyrsa --batch revoke $CLIENT
		EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
		rm -rf pki/reqs/$CLIENT.req
		rm -rf pki/private/$CLIENT.key
		rm -rf pki/issued/$CLIENT.crt
		rm -rf /etc/openvpn/crl.pem
		cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
		chmod 644 /etc/openvpn/crl.pem
		rm /home/vps/public_html/$CLIENT.ovpn
		echo ""
		echo "Client Name " $CLIENT " Removed."
		echo ""
		exit
	;;


	3)
		clear
		echo ""
		echo -e "${RED}All Client in Server${NC}"
		tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
	;;


	4)
		clear
		if [ -f "/etc/openvpn/openvpn-status.log" ]; then
			line=`cat /etc/openvpn/openvpn-status.log | wc -l`
			a=$((3+((line-8)/2)))
			b=$(((line-8)/2))

			echo ""
			echo "${RED}All User Online Now${NC}";
			echo ""
			echo "==========================================";
			cat /etc/openvpn/openvpn-status.log | head -n $a | tail -n $b | cut -d "," -f 1 | sed -e 's/,/   /g' > /tmp/vpn-login-db.txt
			cat /tmp/vpn-login-db.txt
		fi
		echo "==========================================";
	;;


	5)
	;;


	6)
		clear
		 if [ ! -e /usr/local/bin/Reboot-Server ]; then
			echo '#!/bin/bash' > /usr/local/bin/Reboot-Server
			echo '' >> /usr/local/bin/Reboot-Server
			echo 'DATE=$(date +"%m-%d-%Y")' >> /usr/local/bin/Reboot-Server
			echo 'TIME=$(date +"%T")' >> /usr/local/bin/Reboot-Server
			echo 'echo "Reboot Date $DATE IN TIME $TIME" >> /usr/local/bin/Reboot-Log' >> /usr/local/bin/Reboot-Server
			echo '/sbin/shutdown -r now' >> /usr/local/bin/Reboot-Server
			chmod +x /usr/local/bin/Reboot-Server
		fi

		echo ""
		echo -e "${RED}Set Time Auto Reboot Server${NC}"
		echo ""
		echo -e "|${RED}1${NC}| Every   1 Hour"
		echo -e "|${RED}2${NC}| Every   6 Hour"
		echo -e "|${RED}3${NC}| Every 12 Hour"
		echo -e "|${RED}4${NC}| Every   1 Day"
		echo -e "|${RED}5${NC}| Every   7 Day"
		echo -e "|${RED}6${NC}| Every 30 Day"
		echo -e "|${RED}7${NC}| Stop Reboot Server"
		echo -e "|${RED}8${NC}| View Log Reboot Server"
		echo -e "|${RED}9${NC}| Clear Log Reboot Server"
		echo ""
		read -p "Select a Menu : " REBOOT

		case $REBOOT in

			1)
				echo "0 * * * * root /usr/local/bin/Reboot-Server" > /etc/cron.d/Reboot-Server
				echo ""
				echo "Already Set Time Reboot Every 1 Hour."
				echo ""
				exit
			;;

			2)
				echo "0 */6 * * * root /usr/local/bin/Reboot-Server" > /etc/cron.d/Reboot-Server
				echo ""
				echo "Already Set Time Reboot Every 6 Hour."
				echo ""
				exit
			;;

			3)
				echo "0 */12 * * * root /usr/local/bin/Reboot-Server" > /etc/cron.d/Reboot-Server
				echo ""
				echo "Already Set Time Reboot Every 12 Hour."
				echo ""
				exit
			;;

			4)
				echo "0 0 * * * root /usr/local/bin/Reboot-Server" > /etc/cron.d/Reboot-Server
				echo ""
				echo "Already Set Time Reboot Every 1 Day."
				echo ""
				exit
			;;

			5)
				echo "0 0 */7 * * root /usr/local/bin/Reboot-Server" > /etc/cron.d/Reboot-Server
				echo ""
				echo "Already Set Time Reboot Every 7 Day."
				echo ""
				exit
			;;

			6)
				echo "0 0 1 * * root /usr/local/bin/Reboot-Server" > /etc/cron.d/Reboot-Server
				echo ""
				echo "Already Set Time Reboot Every 30 Day."
				echo ""
				exit
			;;

			7)
				rm -f /usr/local/bin/Reboot-Server
				echo ""
				echo "Already Stop Reboot Server."
				echo ""
				exit
			;;

			8)
				if [[ -e /usr/local/bin/Reboot-Log ]]; then
					echo ""
					echo "You No Have Log Reboot Server."
					echo ""
					exit
				else
					clear
					echo ""
					cat /usr/local/bin/Reboot-Log
					echo ""
					exit
				fi
			;;

			9)
				echo "" > /usr/local/bin/Reboot-Log
				echo ""
				echo "Already Clear Log Reboot Server."
				echo ""
				exit
			;;

		esac
	;;

	7)
	;;
	8)
	;;
	9)
	;;
	10)
#		rm /usr/local/bin/Menu
#		wget -O /usr/local/bin/Menu "Link"
		chmod +x /usr/local/bin/Menu
	;;

	

esac
