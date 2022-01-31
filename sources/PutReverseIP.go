/*
#
#  @project     AWS Terraform MAP-R
#  @package     Set private DNS records
#  @subpackage  PutReverseIP
#  @access
#  @paramtype	index of array : 0 : master-node , 1 : worker node 1 ...
#				json format in {"indexnodes":"$count.index}"
#  @argument
#  @description  Return json format Reverse IP : {"IPR":"ip reverse"}
#				 from the nodehost.json file
#
#  @author Emmanuel COLUSSI
#  @version 1.00
*/

package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net"
	"os"
	"strconv"
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

type nodeindex struct {
	Indexnodes string `json:"indexnodes"`
}

func main() {

	var FileName string = "nodehost.json"
	var config []instances
	var s string = ""
	var Nodeindex nodeindex

	// Reading the standard input
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		s = s + scanner.Text()
	}
	// Decode json input
	json.Unmarshal([]byte(s), &Nodeindex)

	// Convert input index to int
	i1, err := strconv.Atoi(Nodeindex.Indexnodes)

	if err == nil {

		jsonFile, err1 := os.Open(FileName)
		// if we os.Open returns an error then handle it
		if err1 != nil {
			fmt.Println(err1)
		}
		// defer the closing of our jsonFile so that we can parse it later on
		defer jsonFile.Close()

		// Decode json file
		byteValue, _ := ioutil.ReadAll(jsonFile)
		json.Unmarshal(byteValue, &config)

		// Print IP Reverse
		result := `{"IPR":"` + config[i1].Ipreverse + `"}`

		fmt.Print(result)

	}

}
