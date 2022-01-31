/*
#
#  @project     AWS Terraform MAP-R
#  @package     Set private DNS records
#  @subpackage  ReverseIP
#  @access
#  @paramtype	hostname,ip: x.x.x.x,sequence 0 : master 1 : worker
#  @argument
#  @description  Return Struct hostname, Private IP, ReverseIP in nodehost.json file
#
#  @author Emmanuel COLUSSI
#  @version 1.00
*/

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"os"
	"strings"
)

func ReverseIPAddress(ip net.IP) string {

	if ip.To4() != nil {
		// split into slice by dot .
		addressSlice := strings.Split(ip.String(), ".")
		reverseSlice := []string{}

		for i := range addressSlice {
			octet := addressSlice[len(addressSlice)-1-i]
			reverseSlice = append(reverseSlice, octet)
		}

		return strings.Join(reverseSlice, ".")

	} else {
		panic("invalid IPv4 address")
	}
}

type instances struct {
	Hostname  string `json:"hostname"`
	Ipp       string `json:"ipp"`
	Ipreverse string `json:"ipreverse"`
}

func (m instances) MarshalJSON() ([]byte, error) {
	j, err := json.Marshal(struct {
		Hostname  string
		Ipp       string
		Ipreverse string
	}{
		Hostname:  m.Hostname,
		Ipp:       m.Ipp,
		Ipreverse: m.Ipreverse,
	})
	if err != nil {
		return nil, err
	}
	return j, nil
}

func main() {

	var FileName string = "nodehost.json"
	var config []instances
	IPNode := net.ParseIP(os.Args[2])
	reverseIpAddress := ReverseIPAddress(IPNode)
	reverseIpAddress = reverseIpAddress + ".in-addr.arpa"

	if os.Args[3] == "0" {
		e := os.Remove(FileName)
		if e != nil {
			log.Fatal(e)

		}

	}

	// test if file : nodehost.json Exist
	if _, err := os.Stat(FileName); err == nil || os.IsExist(err) {

		jsonFile, err1 := os.Open(FileName)
		// if we os.Open returns an error then handle it
		if err1 != nil {
			fmt.Println(err)
		}
		// defer the closing of our jsonFile so that we can parse it later on
		defer jsonFile.Close()

		byteValue, _ := ioutil.ReadAll(jsonFile)
		json.Unmarshal(byteValue, &config)

		// Add new struct record
		config = append(config, instances{Hostname: os.Args[1], Ipp: os.Args[2], Ipreverse: reverseIpAddress})

		result, err := json.Marshal(config)
		if err != nil {
			log.Println(err)
		}
		// write in nodehost.json File
		err = ioutil.WriteFile(FileName, result, 0644)
		if err != nil {
			log.Println(err)
		}

	} else if os.IsNotExist(err) {

		workertab := []instances{instances{Hostname: os.Args[1], Ipp: os.Args[2], Ipreverse: reverseIpAddress}}

		workertab1, err := json.Marshal(workertab)
		if err != nil {
			log.Println(err)

		}
		// Creat a File : nodehost.json and write a first worker

		err = ioutil.WriteFile(FileName, workertab1, 0644)
		if err != nil {
			log.Println(err)
		}

	}

}
