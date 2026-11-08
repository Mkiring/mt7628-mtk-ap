/*
 ***************************************************************************
 * Ralink Tech Inc.
 * Device Tree Resource Parser for MT7628 WiFi RBUS Driver
 ***************************************************************************
*/

#ifdef RTMP_RBUS_SUPPORT

#include "rt_config.h"
#include <linux/of.h>
#include <linux/platform_device.h>

/**
 * rt2880_get_hw_resources - Get hardware resources from device tree
 * @mem: Output pointer for memory region resource
 * @irq: Output IRQ number
 *
 * Returns 0 on success, negative error code on failure.
 */
int __init rt2880_get_hw_resources(struct resource **mem, int *irq)
{
	struct device_node *np;
	struct resource res;
	int ret;

	np = of_find_compatible_node(NULL, NULL, "mediatek,mt7628-wmac");
	if (!np) {
		pr_warn("mt7628: No DT node for mediatek,mt7628-wmac\n");
		return -ENODEV;
	}

	ret = of_address_to_resource(np, 0, &res);
	if (ret) {
		pr_err("mt7628: Failed to parse reg: %d\n", ret);
		of_node_put(np);
		return ret;
	}

	*mem = kmemdup(&res, sizeof(res), GFP_KERNEL);
	if (!*mem) {
		of_node_put(np);
		return -ENOMEM;
	}

	*irq = irq_of_parse_and_map(np, 0);
	if (*irq == 0) {
		pr_err("mt7628: Failed to parse IRQ\n");
		kfree(*mem);
		*mem = NULL;
		of_node_put(np);
		return -EINVAL;
	}

	of_node_put(np);
	pr_info("mt7628: DT resources: mem=0x%llx, irq=%d\n",
		(unsigned long long)(*mem)->start, *irq);
	return 0;
}
EXPORT_SYMBOL(rt2880_get_hw_resources);

#endif /* RTMP_RBUS_SUPPORT */
